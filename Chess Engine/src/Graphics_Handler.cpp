#include "Graphics_Handler.h"
#include "Bitboard.h"

#include <SFML/Graphics.hpp>

#include <iostream>

Graphics_Handler::Graphics_Handler()
{
	window = new sf::RenderWindow(sf::VideoMode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE);
	selectedSquare = -1;
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
			int nSquare = Bitboard::getSquare(i, j);

			sf::RectangleShape square(sf::Vector2f(SQUARE_SIZE, SQUARE_SIZE));
			square.setPosition(i * SQUARE_SIZE, j * SQUARE_SIZE);
			if ((i + j) % 2 == 0)
			{
				square.setFillColor(LIGHT_SQUARE_COLOR);

				if (nSquare == selectedSquare)
				{
					square.setFillColor(SELECTED_LIGHT_SQUARE_COLOR);
				}
			}
			else
			{
				square.setFillColor(DARK_SQUARE_COLOR);

				if (nSquare == selectedSquare)
				{
					square.setFillColor(SELECTED_DARK_SQUARE_COLOR);
				}
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

		std::string spritePath = board.getPieceSprite(piece);

		pieceTexture.loadFromFile(spritePath);

		pieceTexture.setSmooth(true);
		pieceShape.setTexture(pieceTexture);
		// Center the piece to the square

		// Center the piece within the square
		
		
		float xOffset = (SQUARE_SIZE - pieceShape.getGlobalBounds().width) / 2.0f;
		float yOffset = (SQUARE_SIZE - pieceShape.getGlobalBounds().height) / 2.0f;
		
		
		
		pieceShape.setPosition((i % BOARD_SIZE) * SQUARE_SIZE + xOffset, (i / BOARD_SIZE) * SQUARE_SIZE + yOffset);

		(*window).draw(pieceShape);
	}		
}

void Graphics_Handler::drawValidPositions(const Bitboard& board, int square)
{
	// Get the valid positions for the piece on the square

	std::vector<int> validPositions = board.getValidPositions(square);

	for (int i = 0; i < validPositions.size(); i++)
	{
		int validPosition = validPositions[i];

		sf::Texture circleTexture;

		circleTexture.loadFromFile("resources\\valid_square.png");
		circleTexture.setSmooth(true);

		sf::Sprite circle;
		circle.setTexture(circleTexture);
		
		float xOffset = (SQUARE_SIZE - circle.getGlobalBounds().width) / 2.0f;
		float yOffset = (SQUARE_SIZE - circle.getGlobalBounds().height) / 2.0f;

		
		circle.setPosition((validPosition % BOARD_SIZE) * SQUARE_SIZE + xOffset, (validPosition / BOARD_SIZE) * SQUARE_SIZE + yOffset);

		(*window).draw(circle);
	}
}

void Graphics_Handler::handleInput(sf::Event event, Bitboard& board)
{
	if (event.type == sf::Event::Closed)
	{
		(*window).close();
	}

	if (event.type == sf::Event::MouseButtonPressed)
	{
		if (event.mouseButton.button == sf::Mouse::Left)
		{
			// Get the square that was clicked

			int x = event.mouseButton.x / SQUARE_SIZE;
			int y = event.mouseButton.y / SQUARE_SIZE;

			int square = Bitboard::getSquare(x, y);

			int turn = board.getTurn();

			int piece = board.getPieceType(square);
			int color = board.getPieceColor(square);

			bool pieceIsTurn = board.pieceIsTurn(square);

			if (piece != EMPTY && pieceIsTurn)
			{
				// Color the square

				if (selectedSquare == square)
				{
					selectedSquare = -1;
					
				}
				else {
					selectedSquare = square;
				}
			}
			else if (selectedSquare != -1)
			{
				// Move the piece

				bool moved = board.move(selectedSquare, square);

				if (moved)
				{
					selectedSquare = -1;
				}

				// redraw the board
				
			}
		}
	}
}

int Graphics_Handler::getSelectedSquare() const
{
	return selectedSquare;
}