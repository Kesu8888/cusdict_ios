import Foundation

class ModelData: ObservableObject {
    @Published var mainFolder: [Folder]
    @Published var currentSelectedFolder: Folder
    @Published var currentSelectedWordlist: WordList
    @Published var setting: SettingsManager
    private let dataConnector: DataConnector
    
    init() {
        dataConnector = DataConnector()
        currentSelectedFolder = Folder(id: "default")
        currentSelectedWordlist = WordList(name: "default WordList", language: .english, passCount: 4, start: false)
        setting = SettingsManager()
        mainFolder = []
        P_MainFolder_LoadFolders()
        test()
    }
    
    func test() {
        // Adding folders
        for i in 0...1 {
            let f = Folder(id: "Folder \(i)")
            guard MainFolder_AddFolder(f: f) else {
                fatalError("Test MainFolder AddFolder fail")
            }
            currentSelectedFolder = f
            // Adding 4 wordlists to each folder
            for j in 1...4 {
                guard Folder_AddWordList(W: WordList(name: "W \(j)", language: .english, passCount: 3, start: true)) else {
                    fatalError("Test Folder AddWordList fail")
                }
            }
        }
        P_MainFolder_LoadFolders()
        currentSelectedFolder = mainFolder[0]
    }
    
    /// False if contains duplicates, not responsible for adding Folder
    func MainFolder_AddFolder(f: Folder) -> Bool {
        guard dataConnector.MainFolder_AddFolder(f: f) else {
            return false
        }
        return true
    }
    
    /// Delete the folder in database, not responsible for deleting Folder in ModelData
    func MainFolder_DeleteFolder(f: Folder) {
        dataConnector.MainFolder_DeleteFolder(f: f)
    }
    
    private func P_MainFolder_LoadFolders() {
        mainFolder = dataConnector.MainFolder_GetFolders()
    }
    
    /// return false Too many duplicate WordList. Not responsible for adding WordList in place.
    func Folder_AddWordList(W: WordList) -> Bool {
        guard dataConnector.Folder_AddWordList(f: currentSelectedFolder, W: W) else {
            return false
        }
        return true
    }
    
    /// not responsible for deleting the wordlist
    func Folder_DeleteWordList(W: WordList) {
        dataConnector.Folder_DeleteWordList(f: currentSelectedFolder, W: W)
    }
    
    func Folder_EditWordList(oldW: WordList, newW: WordList) -> Bool {
        if oldW.name == newW.name {
            dataConnector.Folder_EditWordList(f: currentSelectedFolder, oldW: oldW, newW: newW)
        } else {
            guard dataConnector.Folder_EditWordList_changeName(f: currentSelectedFolder, oldW: oldW, newW: newW) else {
                return false
            }
        }
        return false
    }
    
    /// ModelData is responsible for adding the word in the database
    func WordList_AddWord(w: Word) -> Bool {
        return dataConnector.WordList_AddWord(f: currentSelectedFolder, W: currentSelectedWordlist, w: w)
    }

    /// ModelData is responsible for deleting the word in the sql database
    func WordList_DeleteWord(w: Word) {
        dataConnector.WordList_DeleteWord(f: currentSelectedFolder, W: currentSelectedWordlist, w: w)
    }
}
