//
//  MorseParagraph.swift
//  morse-coder
//
//  Created by labuser on 9/2/18.
//  Copyright © 2018 mc. All rights reserved.
//

import Foundation
import AVFoundation

class MorseParagraph {
    
    enum MorseError : Error {
        case CharacterNotInDictionary
        case EmptyDictionary
        case CouldNotFindAudio
    }
    
    var words : String = ""
    var morseArr : [String] = []
    var morseWords : String = ""
    var player = AVQueuePlayer(items: [])
    
    static var translationDict : [String : String] = getTranslationDict()
    static let audioFileNames : [Character : String] = [".": "di", "-": "dah" , " ": "short_gap", "|": "long_gap"]
    static var audioFiles : [String : URL] = getAudioFiles()
    
    init (textToTranslate : String) throws {
        words = textToTranslate
        
        morseArr = try MorseParagraph.toMorse(words: words)
        
        morseWords = morseArr.reduce("", { (prev, curr) in
            if !prev.isEmpty && curr != "|" && prev.last != "|"  {
                return prev + " " + curr
            }
            else {
                return prev + curr
            }
        })
    }
    
    static func getTranslationDict() -> [String : String] {
        if let url = Bundle.main.url(forResource: "Morse", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String : String]
            } catch {
                print(error)
            }
        }
        return [:]
    }
    
    static func toMorse(words: String) throws -> [String] {
        if translationDict.count == 0 {
            throw MorseError.EmptyDictionary
        }
        
        let unicodeArr = Array(words.uppercased())
        
        let morseArr = try unicodeArr.map{ (character) -> String in
            let morseTranslation = MorseParagraph.translationDict[String(character)]
            if morseTranslation != nil {
                return morseTranslation!
            } else {
                throw MorseError.CharacterNotInDictionary
            }
        }
        
        return morseArr
    }
    
    static func getAudioFiles() -> [String : URL]  {
        var audioFiles : [String : URL] = [:]
        
        for fileName in audioFileNames.values {
            let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")
            audioFiles[fileName] = url
        }
        
        return audioFiles
    }
    
    func playMorse() throws {
        var audioQueue : [AVPlayerItem] = []
        
        do {
            for sound in Array(morseWords) {
                let fileName = MorseParagraph.audioFileNames[sound]
                
                if fileName == nil {
                    throw MorseError.CouldNotFindAudio
                }
                
                let url = MorseParagraph.audioFiles[fileName!]
                
                let item = AVPlayerItem(url: url!)
                audioQueue.append(item)
            }
        } catch let error as MorseError{
            throw error
        } catch {
            print(error)
        }
        
        player = AVQueuePlayer(items: audioQueue)
        player.play()
    }
    
    func getWords() -> String {
        return words
    }
    
    func getMorse() -> String {
        
        
        return morseWords
    }
}
