#pragma once

#ifndef BITBOARD_H
#define BITBOARD_H

#include <string>
#include <iostream>

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

	void clearBoard();

	// FEN

	void loadFEN(std::string fen);


private:
	int board[BOARD_SIZE * BOARD_SIZE];
};

#endif