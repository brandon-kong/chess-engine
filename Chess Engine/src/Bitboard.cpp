#include "Bitboard.h"

#include <iostream>
#include <vector>
#include <string>

Bitboard::Bitboard()
{
	for (int i = 0; i < BOARD_SQUARES; i++)
	{
		board[i] = 0;
	}
}

Bitboard::~Bitboard()
{
}

const int* Bitboard::getBoard() const
{
	return board;
}

void Bitboard::printBoard() const
{
	for (int i = 0; i < BOARD_SQUARES; i++)
	{
		std::cout << board[i] << " ";
		if ((i + 1) % BOARD_SIZE == 0)
		{
			std::cout << std::endl;
		}
	}
}

void Bitboard::clearBoard()
{
	for (int i = 0; i < BOARD_SQUARES; i++)
	{
		board[i] = 0;
	}
}

int Bitboard::getPieceType(int square) const
{
	return board[square] & (PAWN | KNIGHT | BISHOP | ROOK | QUEEN | KING);
}

int Bitboard::getPieceColor(int square) const
{
	return board[square] & (WHITE | BLACK);
}

void Bitboard::loadFEN(std::string fen)
{
	clearBoard();

	int square = 0;

	for (int i = 0; i < fen.length(); i++)
	{
		char c = fen[i];

		if (c == '/')
		{
			continue;
		}

		if (c >= '1' && c <= '8')
		{
			square += c - '0';
		}
		else
		{
			int piece = 0;

			switch (c)
			{
			case 'p':
				piece = PAWN;
				break;
			case 'n':
				piece = KNIGHT;
				break;
			case 'b':
				piece = BISHOP;
				break;
			case 'r':
				piece = ROOK;
				break;
			case 'q':
				piece = QUEEN;
				break;
			case 'k':
				piece = KING;
				break;
			case 'P':
				piece = PAWN | WHITE;
				break;
			case 'N':
				piece = KNIGHT | WHITE;
				break;
			case 'B':
				piece = BISHOP | WHITE;
				break;
			case 'R':
				piece = ROOK | WHITE;
				break;
			case 'Q':
				piece = QUEEN | WHITE;
				break;
			case 'K':
				piece = KING | WHITE;
				break;
			}

			board[square] = piece;

			square++;
		}
	}
}