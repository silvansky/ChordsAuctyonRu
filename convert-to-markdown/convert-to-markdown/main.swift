//
//  main.swift
//  convert-to-markdown
//
//  Created by Valentine Silvansky on 22.08.2022.
//

import Foundation

let inputFile = "/Users/valentine/Projects/ChordsAuctyonRu/chords.html"

let songStartMarker = "<a class=\"song-link\" name="
let songEndMarker = "</a>"

func parseSongName(_ line: String) -> String {
    let startMarker = "<b>"
    let endMarker = " (аккорды):</b>"
    guard let startMarkerRange = line.range(of: startMarker),
          let endMarkerRange = line.range(of: endMarker)
    else {
        print("Failed to process:")
        print(line)
        return "none"
    }
    let name = line[startMarkerRange.upperBound...endMarkerRange.lowerBound]

    return String(name).trimmingCharacters(in: .whitespacesAndNewlines)
}

func parseSongLabel(_ line: String) -> String {
    let elements = line.components(separatedBy: "\"")
    return elements[3]
}

struct Song {
    var name: String
    var label: String
    var content: String
}

func processLines(_ lines: [String]) -> [Song] {
    var songs: [Song] = []

    var i = 0

    while i < lines.count {
        let currentLine = lines[i]

        if currentLine.starts(with: songStartMarker) {
            let currentSongName = parseSongName(currentLine)
            let currentSongLabel = parseSongLabel(currentLine)

            print("Found song \"\(currentSongName)\" with label \"\(currentSongLabel)\"")

            var currentSongContent = "# \(currentSongName)\n```\n"

            var songEndFound = false

            i = i + 1

            while !songEndFound {
                let currentLine = lines[i]
                songEndFound = currentLine.starts(with: songEndMarker)

                if !songEndFound {
                    currentSongContent += "\(currentLine)\n"
                } else {
                    currentSongContent += "```"
                }

                i = i + 1
            }

            print("Song content:\n\(currentSongContent)")

            let song = Song(name: currentSongName, label: currentSongLabel, content: currentSongContent)

            songs.append(song)
        }

        i = i + 1
    }

    return songs
}

func saveSongs(_ songs: [Song]) {
    var tableOfContents: String = """
# Аккорды группы АукцЫон и Леонида Фёдорова

Переехали с сайта chords.auctyon.ru

## Песни


"""
    for song in songs {
        let markdownFileName = "songs/\(song.label).md"
        let filePath = "/Users/valentine/Projects/ChordsAuctyonRu/\(markdownFileName)"

        let relativeLink = "[\(song.name)](\(markdownFileName))"

        tableOfContents += "- \(relativeLink)\n"

        var songContent = song.content

        songContent += "\n[Список песен](../README.md)"

        do {
            try songContent.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save file \(filePath): \(error)")
        }
    }

    let tableOfContentsPath = "/Users/valentine/Projects/ChordsAuctyonRu/README.md"

    do {
        try tableOfContents.write(toFile: tableOfContentsPath, atomically: true, encoding: .utf8)
    } catch {
        print("Failed to save file \(tableOfContentsPath): \(error)")
    }
}

func processFile() {
    do {
        let data = try String(contentsOfFile: inputFile, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)
        let songs = processLines(lines)
        saveSongs(songs)
    } catch {
        print(error)
    }
}

processFile()
