#pragma once

#ifndef BITBOARD_H
#define BITBOARD_H

#include <string>
#include <iostream>
#include <map>
#include <vector>

const uint64_t PAWN = 6;
const uint64_t KNIGHT = 5;
const uint64_t BISHOP = 4;
const uint64_t ROOK = 3;
const uint64_t QUEEN = 2;
const uint64_t KING = 1;

const uint64_t WHITE = 8;
const uint64_t BLACK = 16;

const uint64_t EMPTY = 0;


// Board constants

const int BOARD_SIZE = 8;
const int BOARD_SQUARES = 64;

// Piece image map

const std::string PIECE_IMAGE_MAP[6] = { "pawn.png", "knight.png", "bishop.png", "rook.png", "queen.png", "king.png" };
const std::map<uint64_t, std::string> PIECE_MAP = {
{PAWN, "pawn.png"}, {KNIGHT, "knight.png"}, {BISHOP, "bishop.png"}, {ROOK, "rook.png"}, {QUEEN, "queen.png"}, {KING, "king.png"} };

// Board square constants

class Bitboard
{
public:
	Bitboard();
	~Bitboard();

	const int* getBoard() const;

	// UTIL
	void printBoard() const;
	int getPieceType(int square) const;
	int getPieceColor(int square) const;

	std::string getPieceSprite(uint64_t piece) const;

	static int getSquare(int x, int y);

	void clearBoard();

	// FEN

	void loadFEN(std::string fen);

	// Board manipulation

	uint64_t getTurn() const;
	void setTurn(int turn);

	void move(int from, int to);

	// Valid moves

	std::vector<int> getValidPositions(int square);



private:
	int board[BOARD_SIZE * BOARD_SIZE];
	int turn;
};

#endif