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

	turn = WHITE;
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

std::string Bitboard::getPieceSprite(uint64_t piece) const
{
	uint64_t type = piece & (PAWN | KNIGHT | BISHOP | ROOK | QUEEN | KING);
	uint64_t color = piece & (WHITE | BLACK);

	std::string pieceString = PIECE_MAP.at(type);
	pieceString = color == WHITE ? "white_" + pieceString : "black_" + pieceString;

	pieceString = "resources\\" + pieceString;

	return pieceString;
}

int Bitboard::getSquare(int x, int y)
{
	return y * BOARD_SIZE + x;
}

uint64_t Bitboard::getTurn() const
{
	return turn;
}

void Bitboard::setTurn(int turn)
{
	this->turn = turn;
}

void Bitboard::move(int from, int to)
{
	board[to] = board[from];
	board[from] = EMPTY;

	turn = turn == WHITE ? BLACK : WHITE;
}

std::vector<int> Bitboard::getValidPositions(int square)
{
	std::vector<int> validPositions;

	int piece = getPieceType(square);
	int color = getPieceColor(square);

	std::cout << piece << std::endl;

	if (piece == PAWN)
	{
		int direction = color == WHITE ? -1 : 1;

		int forward = square + direction * BOARD_SIZE;

		if (getPieceType(forward) == EMPTY)
		{
			validPositions.push_back(forward);

			if (color == WHITE && square / BOARD_SIZE == 6 || color == BLACK && square / BOARD_SIZE == 1)
			{
				int forward2 = forward + direction * BOARD_SIZE;

				if (getPieceType(forward2) == EMPTY)
				{
					validPositions.push_back(forward2);
				}
			}
		}

		int left = square + direction * BOARD_SIZE - 1;
		int right = square + direction * BOARD_SIZE + 1;

		if (getPieceType(left) != EMPTY && getPieceColor(left) != color)
		{
			validPositions.push_back(left);
		}

		if (getPieceType(right) != EMPTY && getPieceColor(right) != color)
		{
			validPositions.push_back(right);
		}
	}
	else if (piece == KNIGHT)
	{
		int x = square % BOARD_SIZE;
		int y = square / BOARD_SIZE;

		int positions[8] = { getSquare(x - 1, y - 2), getSquare(x + 1, y - 2), getSquare(x - 2, y - 1), getSquare(x + 2, y - 1), getSquare(x - 2, y + 1), getSquare(x + 2, y + 1), getSquare(x - 1, y + 2), getSquare(x + 1, y + 2) };

		for (int i = 0; i < 8; i++)
		{
			int position = positions[i];

			if (position >= 0 && position < BOARD_SQUARES)
			{
				if (getPieceType(position) == EMPTY || getPieceColor(position) != color)
				{
					validPositions.push_back(position);
				}
			}
		}
	}
	else if (piece == BISHOP)
	{
		int x = square % BOARD_SIZE;
		int y = square / BOARD_SIZE;

		int	position = getSquare(x - 1, y - 1);

		while (position >= 0 && position < BOARD_SQUARES && getPieceType(position) == EMPTY)
		{
			validPositions.push_back(position);

			x = position % BOARD_SIZE;
			y = position / BOARD_SIZE;

			position = getSquare(x - 1, y - 1);
		}
	}

	return validPositions;
}