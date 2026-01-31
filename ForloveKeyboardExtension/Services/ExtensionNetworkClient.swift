import Foundation

// MARK: - 键盘扩展网络客户端 V2
// 支持新的槽位矩阵结构，通过自有服务器调用 DeepSeek API

public final class ExtensionNetworkClient {
    
    public static let shared = ExtensionNetworkClient()
    
    // MARK: - 配置
    
    /// 服务端 API 地址
    private let apiEndpoint = "https://aiin.bytepig.xyz/generate.php"
    
    /// 请求超时时间
    private let timeout: TimeInterval = 30
    
    /// URLSession
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        return URLSession(configuration: config)
    }()
    
    /// 当前任务（用于取消重复请求）
    private var currentTask: URLSessionDataTask?
    
    private init() {}
    
    // MARK: - 生成请求（新槽位系统）
    
    /// 使用槽位发送生成请求
    /// - Parameters:
    ///   - slot: 分类槽位
    ///   - content: 输入内容（对方消息/原话/问题等）
    ///   - identity: 用户身份
    ///   - chatContext: 聊天上下文（可选）
    ///   - completion: 完成回调
    public func generate(
        slot: CategorySlot,
        content: String,
        identity: UserIdentity,
        chatContext: String? = nil,
        completion: @escaping (Result<[Candidate], NetworkError>) -> Void
    ) {
        // 取消之前的请求
        currentTask?.cancel()
        
        // 构建请求体
        let requestBody = buildSlotRequestBody(
            slot: slot,
            content: content,
            identity: identity,
            chatContext: chatContext
        )
        
        guard let url = URL(string: apiEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        // 发送请求
        currentTask = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleSlotResponse(
                    data: data,
                    response: response,
                    error: error,
                    slot: slot,
                    completion: completion
                )
            }
        }
        
        currentTask?.resume()
    }
    
    // MARK: - 向后兼容的生成请求
    
    /// 发送生成请求（向后兼容旧接口）
    /// - Parameters:
    ///   - spec: 生成规格
    ///   - identity: 用户身份
    ///   - style: 风格偏好
    ///   - completion: 完成回调
    public func generate(
        spec: GenSpec,
        identity: UserIdentity,
        style: StyleProfile,
        completion: @escaping (Result<[Candidate], NetworkError>) -> Void
    ) {
        // 取消之前的请求
        currentTask?.cancel()
        
        // 构建请求体
        let requestBody = buildRequestBody(spec: spec, identity: identity, style: style)
        
        guard let url = URL(string: apiEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.encodingError))
            return
        }
        
        // 发送请求
        currentTask = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleResponse(data: data, response: response, error: error, tag: spec.toneTag, completion: completion)
            }
        }
        
        currentTask?.resume()
    }
    
    // MARK: - 构建槽位请求体
    
    private func buildSlotRequestBody(
        slot: CategorySlot,
        content: String,
        identity: UserIdentity,
        chatContext: String?
    ) -> [String: Any] {
        let styleParams = slot.effectiveStyleParams
        
        // 构建上下文
        var context: [String: Any] = [
            "display_name": identity.displayName,
            "persona": identity.personaDescription,
            "relationship_goal": identity.relationshipGoal.rawValue,
            "speaking_style": identity.speakingStyle.rawValue,
            "language": identity.language.rawValue,
            "user_gender": identity.gender.rawValue,
            "target_gender": "未知",
            "stage": identity.relationshipGoal.rawValue,
            "style": identity.speakingStyle.rawValue,
            "main_category": mapMainCategoryToServer(slot.mainCategory),
            "sub_category": mapSubCategoryToServer(slot.selectedSubCategory),
            "ambiguity": styleParams.ambiguity,
            "emoji_density": styleParams.emojiDensity.promptValue,
            "length": styleParams.length.promptValue
        ]
        
        // 添加雷区
        if !identity.tabooList.isEmpty {
            context["taboo_list"] = identity.tabooDescription
        }
        
        // 添加聊天上下文
        if let chatContext = chatContext, !chatContext.isEmpty {
            context["chat_context"] = chatContext
        }
        
        // 根据主分类添加特定字段
        switch slot.mainCategory {
        case .reply, .rolePlay, .lifeWiki:
            context["last_message"] = content
        case .opener:
            // opener 不需要输入内容
            break
        case .polish:
            context["raw_text"] = content
        }
        
        // 风格参数
        let styleParamsDict: [String: Any] = [
            "ambiguity": styleParams.ambiguity,
            "emoji_density": styleParams.emojiDensity.promptValue,
            "length": styleParams.length.promptValue
        ]
        
        // 构建最终请求体
        var configV2Params: [String: Any] = [
            "word_count": slot.configV2?.wordCount.rawValue ?? "中",
            "aggression_level": slot.configV2?.aggressionLevel.rawValue ?? "中",
            "adult_style": slot.configV2?.adultStyle.rawValue ?? "无"
        ]
        
        return [
            "main_category": mapMainCategoryToServer(slot.mainCategory),
            "sub_category": mapSubCategoryToServer(slot.selectedSubCategory),
            "count": 3,
            "context": context,
            "style_params": styleParamsDict,
            "config_v2": configV2Params
        ]
    }
    
    /// 主分类映射到服务端字符串
    private func mapMainCategoryToServer(_ category: MainCategory) -> String {
        switch category {
        case .reply: return "reply"
        case .opener: return "opener"
        case .polish: return "polish"
        case .rolePlay: return "rolePlay"
        case .lifeWiki: return "lifeWiki"
        }
    }
    
    /// 子分类映射到服务端字符串
    private func mapSubCategoryToServer(_ subCategory: SubCategory) -> String {
        switch subCategory {
        // Reply（帮你回）- 9个
        case .highEQ: return "highEQ"
        case .flirty: return "flirty"
        case .tease: return "tease"
        case .polite: return "polite"
        case .praiseReply: return "praiseReply"
        case .coldCEO: return "coldCEO"
        case .rational: return "rational"
        case .humorResolve: return "humorResolve"
        case .roastMode: return "roastMode"
        
        // Opener（帮开场）- 6个
        case .humorBreaker: return "humorBreaker"
        case .curiousQuestion: return "curiousQuestion"
        case .momentsCutIn: return "momentsCutIn"
        case .directBall: return "directBall"
        case .dailyChat: return "dailyChat"
        case .lightPraise: return "lightPraise"
        
        // Polish（帮润色）- 8个
        case .professional: return "professional"
        case .deGreasy: return "deGreasy"
        case .literary: return "literary"
        case .concise: return "concise"
        case .moreEmotional: return "moreEmotional"
        case .funnier: return "funnier"
        case .moreFormal: return "moreFormal"
        case .moreCasual: return "moreCasual"
        
        // RolePlay（角色代入）- 12个
        case .lawyer: return "lawyer"
        case .doctor: return "doctor"
        case .programmer: return "programmer"
        case .accountant: return "accountant"
        case .topSales: return "topSales"
        case .fitnessCoach: return "fitnessCoach"
        case .psychologist: return "psychologist"
        case .careerMentor: return "careerMentor"
        case .productManager: return "productManager"
        case .toxicCritic: return "toxicCritic"
        case .philosopher: return "philosopher"
        case .loveCoach: return "loveCoach"
        
        // LifeWiki（生活百科）- 6个
        case .quickExplain: return "quickExplain"
        case .coreSteps: return "coreSteps"
        case .mythBuster: return "mythBuster"
        case .shoppingAdvice: return "shoppingAdvice"
        case .avoidPitfalls: return "avoidPitfalls"
        case .prosConsCompare: return "prosConsCompare"
        }
    }
    
    // MARK: - 构建请求体（向后兼容）
    
    private func buildRequestBody(
        spec: GenSpec,
        identity: UserIdentity,
        style: StyleProfile
    ) -> [String: Any] {
        
        // 构建上下文
        var context: [String: Any] = [
            "user_gender": identity.gender.rawValue,
            "target_gender": "未知",
            "stage": identity.relationshipGoal.rawValue,
            "style": identity.speakingStyle.rawValue
        ]
        
        // 根据模式添加特定字段
        switch spec.intent {
        case .reply:
            context["last_message"] = spec.lastMessage ?? ""
        case .opener:
            break
        case .polish:
            context["raw_text"] = spec.rawText ?? ""
        }
        
        return [
            "intent": spec.intent.rawValue,
            "tag": mapToneTagToServer(spec.toneTag),
            "count": spec.candidateCount,
            "context": context
        ]
    }
    
    /// 将 ToneTag 枚举映射到服务端字符串（向后兼容）
    private func mapToneTagToServer(_ tag: ToneTag) -> String {
        switch tag {
        case .common: return "common"
        case .highEQ: return "highEQ"
        case .flirty: return "flirty"
        case .politeRefuse: return "politeRefuse"
        case .professional: return "professional"
        case .generalOpener: return "generalOpener"
        case .newFriend: return "newFriend"
        case .whatUp: return "whatUp"
        case .askOut: return "askOut"
        case .afterDate: return "afterDate"
        case .moreNatural: return "moreNatural"
        case .moreHumorous: return "moreHumorous"
        case .moreFormal: return "moreFormal"
        case .shorter: return "shorter"
        case .heartfelt: return "heartfelt"
        }
    }
    
    // MARK: - 处理槽位响应
    
    private func handleSlotResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        slot: CategorySlot,
        completion: @escaping (Result<[Candidate], NetworkError>) -> Void
    ) {
        // 检查取消
        if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
            return
        }
        
        // 检查网络错误
        if let error = error {
            completion(.failure(.networkError(error)))
            return
        }
        
        // 检查 HTTP 状态码
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
        }
        
        // 检查数据
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        
        // 解析 JSON
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let success = json?["success"] as? Bool, success else {
                let errorMsg = json?["error"] as? String ?? "未知错误"
                completion(.failure(.apiError(errorMsg)))
                return
            }
            
            guard let candidatesArray = json?["candidates"] as? [[String: Any]] else {
                completion(.failure(.parseError))
                return
            }
            
            // 转换为 Candidate 对象
            let candidates = candidatesArray.compactMap { dict -> Candidate? in
                guard let text = dict["text"] as? String else { return nil }
                let _ = dict["preview"] as? String // 记录响应中可能包含的预览，暂时不用
                let tone = dict["tone"] as? String ?? slot.selectedSubCategory.rawValue
                
                var candidate = Candidate(text: text, tags: [tone])
                // 如果有预览，可以存储在 tags 中或者扩展 Candidate 模型
                return candidate
            }
            
            if candidates.isEmpty {
                completion(.failure(.parseError))
            } else {
                completion(.success(candidates))
            }
            
        } catch {
            completion(.failure(.parseError))
        }
    }
    
    // MARK: - 处理响应（向后兼容）
    
    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        tag: ToneTag,
        completion: @escaping (Result<[Candidate], NetworkError>) -> Void
    ) {
        // 检查取消
        if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
            return
        }
        
        // 检查网络错误
        if let error = error {
            completion(.failure(.networkError(error)))
            return
        }
        
        // 检查 HTTP 状态码
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
        }
        
        // 检查数据
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        
        // 解析 JSON
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let success = json?["success"] as? Bool, success else {
                let errorMsg = json?["error"] as? String ?? "未知错误"
                completion(.failure(.apiError(errorMsg)))
                return
            }
            
            guard let candidatesArray = json?["candidates"] as? [[String: Any]] else {
                completion(.failure(.parseError))
                return
            }
            
            // 转换为 Candidate 对象
            let candidates = candidatesArray.compactMap { dict -> Candidate? in
                guard let text = dict["text"] as? String else { return nil }
                let tone = dict["tone"] as? String ?? tag.rawValue
                return Candidate(text: text, tags: [tone])
            }
            
            if candidates.isEmpty {
                completion(.failure(.parseError))
            } else {
                completion(.success(candidates))
            }
            
        } catch {
            completion(.failure(.parseError))
        }
    }
    
    // MARK: - 取消请求
    
    public func cancelCurrentRequest() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - 错误类型
    
    public enum NetworkError: Error, LocalizedError {
        case invalidURL
        case encodingError
        case networkError(Error)
        case serverError(Int)
        case noData
        case parseError
        case apiError(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "请求地址无效"
            case .encodingError:
                return "请求数据编码失败"
            case .networkError(let error):
                return "网络错误：\(error.localizedDescription)"
            case .serverError(let code):
                return "服务器错误（\(code)）"
            case .noData:
                return "服务器无响应"
            case .parseError:
                return "解析响应失败"
            case .apiError(let message):
                return message
            }
        }
    }
}
