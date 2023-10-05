//
//  CreateFileInteractor.swift
//  UltraCore
//
//  Created by Slam on 6/5/23.
//

import RxSwift


class CreateFileInteractor: UseCase<(data: Data, extens: String), [FileChunk]> {

     private let fileService: FileServiceClientProtocol

     init(fileService: FileServiceClientProtocol) {
         self.fileService = fileService
     }

    override func executeSingle(params: (data: Data, extens: String)) -> Single<[FileChunk]> {
        return Single.create { [weak self] observer -> Disposable in

            guard let `self` = self else { return Disposables.create() }
            let request = FileCreateRequest.with({
                $0.name = params.data.hashValue.description
                $0.size = Int64(params.data.count)
                $0.mimeType =  params.extens
            })

            self.fileService
                .create(request, callOptions: .default())
                .response
                .whenComplete { [weak self] result in
                    guard let `self` = self else { return observer(.failure(NSError.selfIsNill)) }
                    switch result {
                    case let .success(response):
                        observer(.success(splitDataIntoChunks(data: params.data, file: response)))
                    case let .failure(error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}

private extension CreateFileInteractor {
    
    func splitDataIntoChunks(data: Data, file response: FileCreateResponse) -> [FileChunk] {
        var chunks: [FileChunk] = []
        data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr)
            let uploadChunkSize = Int(response.chunkSize)
            let totalSize = data.count
            var offset = 0
            var seqNumber: Int64 = 0
            while offset < totalSize {
                let chunkSize = offset + uploadChunkSize > totalSize ? totalSize - offset : uploadChunkSize
                chunks.append(FileChunk.with({ file in
                    file.fileID = response.fileID
                    file.data = Data(bytesNoCopy: mutRawPointer + offset, count: chunkSize, deallocator: Data.Deallocator.none)
                    file.seqNum = seqNumber
                }))
                seqNumber += 1
                offset += chunkSize
            }
        }
        return chunks
    }
}
