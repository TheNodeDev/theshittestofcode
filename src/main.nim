import nico
import httpclient
import json
import math
import strformat
import strutils
import whisky
import os

const orgName = "tk.tubbygames.c44"
const appName = "connect4"

var buttonDown = false

type Gamestate = object
  board: array[7,array[6,int]]

type BoardState = object
  games: array[3,array[3,Gamestate]]
  gameswon: array[3,array[3,bool]]
  opponent: string

var ip = ""
if fileExists("./ip.txt"):
  ip = syncio.readFile("./ip.txt")
else:
  echo "Please enter server IP into ip.txt!"
  quit()

echo "Enter Player Index (1 or 2)"
var playerINDEX = parseInt(readLine(stdin))
echo "Enter Room Code"
var roomCode = readLine(stdin)
var currentBoardState : BoardState
var inGame = true
var lastPlayerPlaced = 0

const colours = [
  1,
  4,
  8
]

var serverSocket = newWebSocket(fmt"ws://{ip}/{roomCode}")
echo "server connected"

proc newGame() =
  var newBoardState: BoardState
  currentBoardState = newBoardState

proc drawGame(g: Gamestate, x, y: int) =
  for bx in 0 .. 6:
    for by in 0 .. 5:
      setColor(colours[g.board[bx][by]])
      pset(bx+x, (5-by)+y)
  discard

proc replaceFirstZero(arr: var array[6, int], newValue: int) =
  for i in 0..<arr.len:
    if arr[i] == 0:
      arr[i] = newValue
      break

proc drawBoard(b: BoardState) =
  for gx in 0 .. 2:
    for gy in 0 .. 2:
      drawGame(b.games[gx][gy], gx*8+1, gy*7+1)

proc placePiece(playerid, gx, gy, col: int) =
  lastPlayerPlaced = playerid
  replaceFirstZero(currentBoardState.games[gx][gy].board[col], playerid)
      

proc placePiece(serverMSG: string) =
  echo serverMSG
  var args = rsplit(serverMSG, " ")
  placePiece(parseInt(args[0]), parseInt(args[1]),parseInt(args[2]),parseInt(args[3]))

proc gameUpdate(dt: float32) =
  let wsMessage = serverSocket.receiveMessage(1)
  if isSome(wsMessage):
    placePiece(wsMessage.get().data)
  
  buttonDown = btn(pcA)
  if mousebtnp(0):
    var mousepos = (mouse()[0]-1, mouse()[1]-1)
    const invalidX = [-1, 7, 15, 23]
    const invalidY = [-1, 6, 13, 20]
    if (not (mousepos[0] in invalidX)) and (not(mousepos[1] in invalidY)):
      var gameFocus = [int(floor(mousepos[0]/8)), int(floor(mousepos[1]/7))]
      var column = mousepos[0] mod 8
      if playerINDEX != lastPlayerPlaced:
        serverSocket.send(fmt"{playerINDEX} {gameFocus[0]} {gameFocus[1]} {column}", TextMessage)

      #echo $floor(mousepos[0]/8) & " : " & $floor(mousepos[1]/7)

proc gameDraw() =
  setColor(6)
  rectfill(0,0,25,22)
  if ingame == false:
    discard
  else:
    drawBoard(currentBoardState)

proc gameInit() =
  newGame()

nico.init(orgName, appName)
nico.createWindow(appName, 25, 22, 16, false)
nico.run(gameInit, gameUpdate, gameDraw)
