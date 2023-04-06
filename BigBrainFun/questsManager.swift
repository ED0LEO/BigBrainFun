//
//  questsManager.swift
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
            deleteButtonIsShown INTEGER NOT NULL DEFAULT 0,
            category TEXT NOT NULL
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
    
    func printAllQuests() {
        let queryStatementString = "SELECT * FROM Quest;"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let title = String(cString: sqlite3_column_text(queryStatement, 1))
                let isCompletedValue = sqlite3_column_int(queryStatement, 2)
                let deleteButtonIsShownValue = sqlite3_column_int(queryStatement, 3)
                let category = Category(rawValue: String(cString: sqlite3_column_text(queryStatement, 4))) ?? .study
                
                let isCompleted = isCompletedValue != 0
                let deleteButtonIsShown = deleteButtonIsShownValue != 0
                
                print("id: \(id), title: \(title), isCompleted: \(isCompleted), deleteButtonIsShown: \(deleteButtonIsShown), category: \(category.rawValue)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }

    
    // Insert a new Quest into the database
    func insertQuest(quest: Quest) {
        let insertStatementString = "INSERT INTO Quest (id, title, isCompleted, deleteButtonIsShown, category) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, quest.id.uuidString, -1, nil)
            sqlite3_bind_text(insertStatement, 2, quest.title, -1, nil)
            sqlite3_bind_int(insertStatement, 3, quest.isCompleted ? 1 : 0)
            sqlite3_bind_int(insertStatement, 4, quest.deleteButtonIsShown ? 1 : 0)
            sqlite3_bind_text(insertStatement, 5, quest.category.rawValue, -1, nil)
            
            print("id is " + quest.id.uuidString)
            print("title is " + quest.title)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(database))
                print("Could not insert row. Error message: \(errmsg)")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func deleteQuest(quest: Quest) {
        let deleteStatementString = "DELETE FROM Quest WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, quest.id.uuidString, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
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
                      let deleteButtonIsShownValue = sqlite3_column_text(queryStatement, 3),
                      let category = sqlite3_column_text(queryStatement, 4)
                else {
                    continue
                }
                
                let isCompleted = isCompletedValue != nil
                let deleteButtonIsShown = deleteButtonIsShownValue != nil
                let quest = Quest(title: String(cString: title),
                                  isCompleted: isCompleted,
                                  deleteButtonIsShown: deleteButtonIsShown,
                                  category: Category(rawValue: String(cString: category)) ?? .study)
                quests.append(quest)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        return quests
    }
    
    deinit {
        closeDatabase()
        print("Database is closed")
    }
}
