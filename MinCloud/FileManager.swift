//
//  FileTable.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

@objc(BAASFileManager)
open class FileManager: Query {

    // MARK: File

    /// 获取文件详情
    ///
    /// - Parameters:
    ///   - fileId: 文件 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func get(_ fileId: String, completion:@escaping FileResultCompletion) -> RequestCanceller? {

        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.getFile(fileId: fileId, parameters: queryArgs)) {  [weak self] result in
            guard let strongSelf = self else { return }
            let (fileInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let file = ResultHandler.dictToFile(dict: fileInfo)
                completion(file, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 查询文件列表
    ///
    /// 先使用 setQuery 方法设置条件，将会获取满足条件的文件。
    /// 如果不设置条件，将获取所有文件。
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func find(_ completion:@escaping FilesResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.findFiles(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (filesInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let files = ResultHandler.dictToFiles(dict: filesInfo)
                completion(files, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 删除多个文件
    ///
    /// - Parameters:
    ///   - fileIds: 文件 Id 数组
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func delete(_ fileIds: [String], completion:@escaping BOOLResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(false, HError.init(code: 604))
            return nil
        }

        queryArgs["id__in"] = fileIds
        let request = FileProvider.request(.deleteFiles(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (_, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 上传文件
    ///
    /// - Parameters:
    ///   - filename: 文件名称
    ///   - localPath: 文件本地路径
    ///   - categoryName: 文件分类
    ///   - progressBlock: progressBlock
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func upload(filename: String, localPath: String, categoryName: String? = nil, progressBlock: @escaping ProgressBlock, completion:@escaping FileResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.upload(parameters: ["filename": filename, "category_name": categoryName as Any])) { result in
            let (fileInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                guard fileInfo != nil, fileInfo?.getString("policy") != nil, fileInfo?.getString("authorization") != nil, fileInfo?.getString("file_link") != nil  else {
                    completion(nil, HError.init(code: 500))
                    return
                }

                let path = fileInfo?.getString("file_link")
                let id = fileInfo?.getString("id")
                let parameters: [String: String] = ["policy": (fileInfo?.getString("policy"))!, "authorization": (fileInfo?.getString("authorization"))!]
                FileProvider.request(.UPUpload(url: (fileInfo?.getString("upload_url"))!, localPath: localPath, parameters: parameters), callbackQueue: nil, progress: { progress in
                    progressBlock(progress.progressObject)
                }, completion: { result in
                    let (fileInfo, error) = ResultHandler.handleResult(result: result)
                    if error != nil {
                        completion(nil, error)
                    } else {
                        var file: File!
                        if let fileInfo = fileInfo {
                            file = File()
                            file.Id = id
                            file.createdAt = fileInfo.getDouble("time")
                            file.mimeType = fileInfo.getString("mimetype")
                            file.name = filename
                            file.size = fileInfo.getInt("file_size")
                            file.cdnPath = path
                        }
                        completion(file, nil)
                    }
                })
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取文件分类
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func getCategoryList(_ completion:@escaping FileCategorysResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.findCategories(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categorysInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let categorys = ResultHandler.dictToFileCategorys(dict: categorysInfo)
                completion(categorys, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    // MARK: FileCategory

    /// 获取分类详情
    ///
    /// - Parameters:
    ///   - Id: 分类 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func getCategory(Id: String, completion:@escaping FileCategoryResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = FileProvider.request(.getCategory(categoryId: Id, parameter: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (categoryInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let category = ResultHandler.dictToFileCategory(dict: categoryInfo)
                completion(category, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 指定分类下的文件列表
    ///
    /// - Parameters:
    ///   - categoryId: 分类 Id
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func getFileList(categoryId: String, completion:@escaping FilesResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        queryArgs["category_id"] = categoryId
        let request = FileProvider.request(.findFilesInCategory(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (filesInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let files = ResultHandler.dictToFiles(dict: filesInfo)
                completion(files, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}