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

	turn = WHITE_TURN;
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

	setTurn(WHITE_TURN);
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

int Bitboard::getTurn() const
{
	return turn;
}

void Bitboard::setTurn(int turn)
{
	this->turn = turn;
}

bool Bitboard::move(int from, int to)
{

	// Check if the move is valid

	if (!isValidMove(from, to))
	{
		return false;
	}

	board[to] = board[from];
	board[from] = EMPTY;

	std::cout << (turn) << std::endl;

	setTurn((turn == WHITE_TURN) ? BLACK_TURN : WHITE_TURN);

	std::cout << (turn) << std::endl;



	return true;
}

std::vector<int> Bitboard::getValidPositions(int square) const
{
	std::vector<int> validPositions;

	int piece = getPieceType(square);
	int color = getPieceColor(square);

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

		int xOffset[] = { -1, 1, -2, 2, -2, 2, -1, 1 };
		int yOffset[] = { -2, -2, -1, -1, 1, 1, 2, 2 };

		for (int i = 0; i < 8; i++)
		{
			int newX = x + xOffset[i];
			int newY = y + yOffset[i];

			int position = getSquare(newX, newY);

			if (newX >= 0 && newX < BOARD_SIZE && newY >= 0 && newY < BOARD_SIZE)
			{
				int position = getSquare(newX, newY);

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

		// handle sliding diagonally

		int xOffset[] = { -1, 1, -1, 1 };
		int yOffset[] = { -1, -1, 1, 1 };

		for (int i = 0; i < 4; i++)
		{
			int newX = x + xOffset[i];
			int newY = y + yOffset[i];

			while (newX >= 0 && newX < BOARD_SIZE && newY >= 0 && newY < BOARD_SIZE)
			{
				int position = getSquare(newX, newY);

				if (getPieceType(position) == EMPTY)
				{
					validPositions.push_back(position);
				}
				else if (getPieceColor(position) != color)
				{
					validPositions.push_back(position);
					break;  // Stop sliding if you encounter a piece of the opposite color
				}
				else
				{
					break;  // Stop sliding if you encounter your own piece
				}

				newX += xOffset[i];
				newY += yOffset[i];
			}
		}
	}

	else if (piece == QUEEN)
	{
		int x = square % BOARD_SIZE;
		int y = square / BOARD_SIZE;

		// handle sliding

		int xOffset[] = { -1, 1, 0, 0, -1, 1, -1, 1 };
		int yOffset[] = { 0, 0, -1, 1, -1, 1, 1, -1 };

		for (int i = 0; i < 8; i++)
		{
			int newX = x + xOffset[i];
			int newY = y + yOffset[i];

			while (newX >= 0 && newX < BOARD_SIZE && newY >= 0 && newY < BOARD_SIZE)
			{
				int position = getSquare(newX, newY);

				if (getPieceType(position) == EMPTY)
				{
					validPositions.push_back(position);
				}
				else if (getPieceColor(position) != color)
				{
					validPositions.push_back(position);
					break; 
				}
				else
				{
					break;
				}

				newX += xOffset[i];
				newY += yOffset[i];
			}
		}

		
	}
	
	else if (piece == KING)
	{
		int x = square % BOARD_SIZE;
		int y = square / BOARD_SIZE;

		int xOffset[] = { -1, 0, 1, -1, 1, -1, 0, 1 };
		int yOffset[] = { -1, -1, -1, 0, 0, 1, 1, 1 };

		for (int i = 0; i < 8; i++)
		{
			int newX = x + xOffset[i];
			int newY = y + yOffset[i];

			int position = getSquare(newX, newY);

			if (newX >= 0 && newX < BOARD_SIZE && newY >= 0 && newY < BOARD_SIZE)
			{
				int position = getSquare(newX, newY);

				if (getPieceType(position) == EMPTY || getPieceColor(position) != color)
				{
					validPositions.push_back(position);
				}
			}		
		}
	}

	else if (piece == ROOK)
	{
		int x = square % BOARD_SIZE;
		int y = square / BOARD_SIZE;

		int xOffset[] = { -1, 1, 0, 0 };
		int yOffset[] = { 0, 0, -1, 1 };

		for (int i = 0; i < 4; i++)
		{
			int newX = x + xOffset[i];
			int newY = y + yOffset[i];

			while (newX >= 0 && newX < BOARD_SIZE && newY >= 0 && newY < BOARD_SIZE)
			{
				int position = getSquare(newX, newY);

				if (getPieceType(position) == EMPTY)
				{
					validPositions.push_back(position);
				}
				else if (getPieceColor(position) != color)
				{
					validPositions.push_back(position);
					break;
				}
				else
				{
					break;
				}

				newX += xOffset[i];
				newY += yOffset[i];
			}
		}
	}

	return validPositions;
}

bool Bitboard::isValidMove(int from, int to) const
{
	std::vector<int> validPositions = getValidPositions(from);

	for (int i = 0; i < validPositions.size(); i++)
	{
		if (validPositions[i] == to)
		{
		return true;
	}
}

	return false;
}

bool Bitboard::pieceIsTurn(int square) const
{
	uint64_t color = getPieceColor(square);

	std::cout << (color) << std::endl;

	return (color == WHITE && turn == WHITE_TURN) || (color == BLACK && turn == BLACK_TURN);
}