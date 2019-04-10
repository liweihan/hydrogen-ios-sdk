//
//  Table.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya
import Result

@objc(BAASTable)
public class Table: NSObject {
    public internal(set) var Id: Int?
    public internal(set) var name: String?
    var identify: String

    @objc public init(tableId: Int) {
        self.identify = String(tableId)
        super.init()
    }

    @objc public init(name: String) {
        self.identify = name
        super.init()
    }

    /// 创建一条空记录
    ///
    /// - Returns:
    @objc public func createRecord() -> TableRecord {
        return TableRecord(table: self)
    }

    /// 示例化一条记录
    ///
    /// - Parameter recordId: 记录 Id
    /// - Returns:
    @objc public func getWithoutData(recordId: String) -> TableRecord {
        return TableRecord(table: self, Id: recordId)
    }

    /// 批量新建记录
    ///
    /// - Parameters:
    ///   - records: 记录值
    ///   - enableTrigger: 是否触发触发器，默认 true。
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func createMany(_ records: [[String: Any]], enableTrigger: Bool = true, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: records, options: .prettyPrinted)
        } catch let error {
            completion(nil, HError.init(code: 400, description: error.localizedDescription))
            return nil
        }

        let request = TableProvider.request(.createRecords(tableId: identify, recordData: jsonData!)) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 批量删除记录
    ///
    /// 先使用 setQuery 方法设置条件，将会删除满足条件的记录。
    /// 如果不设置条件，将删除该表的所有记录。
    ///
    /// - Parameters:
    ///   - enableTrigger: 是否触发触发器，默认值 true
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func delete(query: Query? = nil, options: [String: Any]? = nil, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var queryArgs: [String: Any] = query?.queryArgs ?? [:]
        queryArgs.merge(options ?? [:])
        let request = TableProvider.request(.delete(tableId: identify, parameters: queryArgs)) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取记录详情
    ///
    /// - Parameters:
    ///   - recordId: 记录 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func get(_ recordId: String, query: Query? = nil, completion:@escaping RecordResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = TableProvider.request(.get(tableId: identify, recordId: recordId, parameters: queryArgs)) { [weak self]  result in
            guard let strongSelf = self else { return }
            let (recordInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let record = ResultHandler.dictToRecord(table: strongSelf, dict: recordInfo)
                completion(record, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 批量更新记录
    ///
    /// 先使用 setQuery 方法设置条件，满足条件的记录将会被更新。
    /// 如果不设置条件，将更新该表的所有记录。
    ///
    /// - Parameters:
    ///   - record: 需要更新的记录值
    ///   - enableTrigger: 是否触发触发器，默认 true
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func update(record: BaseRecord, query: Query? = nil, enableTrigger: Bool = true, completion:@escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = TableProvider.request(.update(tableId: identify, urlParameters: queryArgs, bodyParameters: record.record)) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询记录
    ///
    /// 先使用 setQuery 方法设置条件，将会获取满足条件的记录。
    /// 如果不设置条件，将获取该表的所有记录。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public func find(query: Query? = nil, completion:@escaping RecordListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = TableProvider.request(.find(tableId: identify, parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (recordsInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let records = ResultHandler.dictToRecordListResult(table: strongSelf, dict: recordsInfo)
                completion(records, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
