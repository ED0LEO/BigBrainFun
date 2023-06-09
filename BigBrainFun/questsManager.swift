//
//  QuestsManager.swift
//  BigBrainFun
//
//  Created by Ed on 05/04/2023.
//

import Foundation
import SQLite3

class QuestsManager: ObservableObject {
    private let databaseFileName = "myDatabase.sqlite3"
    private var database: OpaquePointer?
    
    init() {
        openDatabase()
        createTable()
    }
    
    private func openDatabase() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not access documents directory")
        }
        
        let databaseURL = documentsDirectory.appendingPathComponent(databaseFileName).path
        
        if sqlite3_open(databaseURL, &database) != SQLITE_OK {
            sqlite3_close(database)
            database = nil
            fatalError("Could not open database.")
        }
    }
    
    private func closeDatabase() {
        if sqlite3_close(database) != SQLITE_OK {
            fatalError("Could not close database.")
        }
        database = nil
    }
    
    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS Quest(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            documentURL TEXT,
            category TEXT NOT NULL,
            completionDate DATE
        );
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(database, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Quest table created.")
            } else {
                print("Quest table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func emptyDatabase() {
        let deleteStatementString = "DELETE FROM Quest;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("All records deleted from Quest table.")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(database))
                print("Could not delete records from Quest table. Error message: \(errmsg)")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func printAllQuests() {
        let queryStatementString = "SELECT * FROM Quest;"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let title = String(cString: sqlite3_column_text(queryStatement, 1))
                let isCompletedValue = sqlite3_column_int(queryStatement, 2)
                let documentURLString = String(cString: sqlite3_column_text(queryStatement, 3))
                let category = Category(rawValue: String(cString: sqlite3_column_text(queryStatement, 4))) ?? .study
                let completionDateValue = sqlite3_column_int(queryStatement, 5)
                let isCompleted = isCompletedValue != 0
                let documentURL = documentURLString.isEmpty ? nil : URL(string: documentURLString)
                let completionDate = Date(timeIntervalSince1970: TimeInterval(completionDateValue))
                
                print("id: \(id), title: \(title), isCompleted: \(isCompleted), documentURL: \(documentURL), category: \(category.rawValue), completionDate: \(completionDate)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func insertQuest(quest: Quest) -> Int {
        let insertStatementString = "INSERT INTO Quest (id, title, isCompleted, documentURL, category, completionDate) VALUES ('\(quest.id)', '\(quest.title)', \(quest.isCompleted ? 1 : 0), '\(quest.documentURL?.absoluteString ?? "")', '\(quest.category.rawValue)', \(quest.completionDate?.timeIntervalSince1970 ?? 0));"
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                sqlite3_finalize(insertStatement)
                return 1
            } else {
                let errmsg = String(cString: sqlite3_errmsg(database))
                print("Could not insert row. Error message: \(errmsg)")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        if insertStatement != nil {
            sqlite3_finalize(insertStatement)
        }
        return 0
    }

    func deleteQuest(quest: Quest) {
        let deleteStatementString = "DELETE FROM Quest WHERE id = '\(quest.id)';"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row with id: '\(quest.id)'.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func updateQuest(id: String, title: String, category: Category, isCompleted: Bool, documentURL: URL, dateCompleted: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: dateCompleted)
        
        let updateStatementString = """
            UPDATE Quest SET
                title = '\(title)',
                isCompleted = \(isCompleted ? 1 : 0),
                category = '\(category.rawValue)',
                documentURL = '\(documentURL.absoluteString)',
                completionDate = strftime('%s', '\(dateString)')
            WHERE id = '\(id)';
            """
        
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(database, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row with id: '\(id)'.")
                print("FROMUPDATEid: \(id), title: \(title), isCompleted: \(isCompleted), documentURL: \(documentURL.absoluteString)), category: \(category.rawValue), completionDate: \(dateString)")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }


    func deleteDatabase() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return
        }
        
        let databaseURL = documentsDirectory.appendingPathComponent(databaseFileName)
        
        do {
            try fileManager.removeItem(at: databaseURL)
            print("Database file deleted")
        } catch {
            print("Error deleting database file: \(error)")
        }
    }
    
    func getAllQuests() -> [Quest] {
        let queryStatementString = "SELECT * FROM Quest;"
        var queryStatement: OpaquePointer?
        var quests: [Quest] = []
        
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                guard let id = sqlite3_column_text(queryStatement, 0),
                      let title = sqlite3_column_text(queryStatement, 1),
                      let isCompletedValue = sqlite3_column_text(queryStatement, 2),
                      let documentURLValue = sqlite3_column_text(queryStatement, 3),
                      let category = sqlite3_column_text(queryStatement, 4)
                else {
                    continue
                }
                
                let isCompleted: Bool
                if let isCompletedValue = sqlite3_column_text(queryStatement, 2) {
                    let isCompletedInt = Int32(sqlite3_column_int(queryStatement, 2))
                    isCompleted = isCompletedInt == 1
                } else {
                    isCompleted = false
                }
                
                let documentURLString = String(cString: documentURLValue)
                let documentURL = !documentURLString.isEmpty ? URL(string: documentURLString) : nil
                
//                let completionDate: Date?
//                if let completionDateValue = sqlite3_column_int64(queryStatement, 5) as? TimeInterval {
//                    completionDate = Date(timeIntervalSince1970: completionDateValue)
//                } else {
//                    completionDate = nil
//                }
                
                let completionDateValue = sqlite3_column_int64(queryStatement, 5)
                let completionDate = completionDateValue > 0 ? Date(timeIntervalSince1970: TimeInterval(completionDateValue)) : nil
                
                /*
                 try later
                 let completionDateValue = sqlite3_column_int64(queryStatement, 5)
                 let completionDate = completionDateValue > 0 ? Date(timeIntervalSince1970: TimeInterval(completionDateValue)) : nil
                 
                 */
                
                print("FROMGETALLid: \(String(cString: id)), title: \(String(cString: title)), isCompleted: \(isCompleted), documentURL: \(String(describing: documentURL)), category: \(Category(rawValue: String(cString: category)) ?? .study), completionDate: \(String(describing: completionDate))")

                let quest = Quest(id: String(cString: id),
                                  title: String(cString: title),
                                  isCompleted: isCompleted,
                                  documentURL: documentURL,
                                  category: Category(rawValue: String(cString: category)) ?? .study,
                                  completionDate: completionDate)
                quests.append(quest)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return quests
    }
    
    
    func getAllQuestIds() -> [String] {
        let queryStatementString = "SELECT id FROM Quest;"
        var queryStatement: OpaquePointer?
        var questIds: [String] = []
        
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                guard let id = sqlite3_column_text(queryStatement, 0) else {
                    continue
                }
                questIds.append(String(cString: id))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return questIds
    }
    
    func getQuestById(id: String) -> Quest? {
        let queryStatementString = "SELECT * FROM Quest WHERE id = '\(id)';"
        var queryStatement: OpaquePointer?
        var quest: Quest?
        
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(queryStatement, 1))
                let isCompletedValue = sqlite3_column_int(queryStatement, 2)
                let documentURLString = String(cString: sqlite3_column_text(queryStatement, 3))
                let documentURL = documentURLString.isEmpty ? nil : URL(string: documentURLString)
                let category = Category(rawValue: String(cString: sqlite3_column_text(queryStatement, 4))) ?? .study
                let completionDate = Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 5))
                
                quest = Quest(id: id, title: title, isCompleted: isCompletedValue != 0, documentURL: documentURL, category: category, completionDate: completionDate)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return quest
    }
    
    deinit {
        closeDatabase()
        print("Database is closed")
    }
}
