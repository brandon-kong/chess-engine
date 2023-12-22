#include "Graphics_Handler.h"
#include "Bitboard.h"

#include <SFML/Graphics.hpp>

#include <iostream>

Graphics_Handler::Graphics_Handler()
{
	window = new sf::RenderWindow(sf::VideoMode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE);
}

Graphics_Handler::~Graphics_Handler()
{
}

void Graphics_Handler::clear()
{
	(*window).clear(sf::Color::Black);
}

void Graphics_Handler::update()
{
}

void Graphics_Handler::display()
{
	(*window).display();
}

sf::RenderWindow* Graphics_Handler::getWindow() const
{
	return window;
}

void Graphics_Handler::drawSquares(const Bitboard& board)
{
	for (int i = 0; i < BOARD_SIZE; i++)
	{
		for (int j = 0; j < BOARD_SIZE; j++)
		{
			sf::RectangleShape square(sf::Vector2f(SQUARE_SIZE, SQUARE_SIZE));
			square.setPosition(i * SQUARE_SIZE, j * SQUARE_SIZE);
			if ((i + j) % 2 == 0)
			{
				square.setFillColor(sf::Color(255, 228, 196));
			}
			else
			{
				square.setFillColor(sf::Color(139, 69, 19));
			}
			(*window).draw(square);
		}
	}
}

void Graphics_Handler::drawPieces(const Bitboard& board)
{
	const int* boardVector = board.getBoard();
	for (int i = 0; i < BOARD_SQUARES; i++)
	{

		std::cout << boardVector[i] << std::endl;

		int piece = boardVector[i];

		if (piece == EMPTY)
		{
			continue;
		}

		// Get piece type

		int pieceType = board.getPieceType(i);

		int pieceColor = board.getPieceColor(i);

		sf::Texture pieceTexture;
		sf::Sprite pieceShape;

		pieceShape.setPosition((i % BOARD_SIZE) * SQUARE_SIZE, (i / BOARD_SIZE) * SQUARE_SIZE);
		//pieceShape.setOrigin(SQUARE_SIZE / 2, SQUARE_SIZE / 2);

		if (pieceColor == WHITE) {
			switch (pieceType) {
				case PAWN:

					pieceTexture.loadFromFile("")
					break;
			}
		}
		else {
			// Black pieces
		}

		pieceShape.setTexture(pieceTexture);
		pieceShape.setPosition((i % BOARD_SIZE) * SQUARE_SIZE, (i / BOARD_SIZE) * SQUARE_SIZE);
		(*window).draw(pieceShape);
	}		
}