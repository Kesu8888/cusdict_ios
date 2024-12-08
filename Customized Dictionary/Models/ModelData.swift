import Foundation

class ModelData: ObservableObject {
    @Published var mainFolder: [Folder]
    @Published var currentSelectedFolder: Folder?
    @Published var currentSelectedWordlist: WordList?
    @Published var currentSelectedWord: Word?
    
    private let dataConnector: DataConnector
    
    init(dataConnector: DataConnector) {
        self.dataConnector = dataConnector
        self.mainFolder = dataConnector.getFolders()
        self.currentSelectedFolder = nil
        self.currentSelectedWordlist = nil
        self.currentSelectedWord = nil
    }
    
    func addFolder(folder: Folder) {
        dataConnector.insertFolderInMainFolder(folder: folder)
        mainFolder.append(folder)
        currentSelectedFolder = folder
    }

    func addWordlist(wordlist: WordList) {
        dataConnector.insertWordlistInFolder(wordlist: wordlist, folder: currentSelectedFolder!)
        currentSelectedFolder!.wordlists.append(wordlist)
        currentSelectedWordlist = wordlist
    }
}