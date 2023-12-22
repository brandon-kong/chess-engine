#include <SFML/Graphics.hpp>
#include "Graphics_Handler.h"

int main()
{
	Graphics_Handler graphics_handler = Graphics_Handler();

	sf::RenderWindow* window = graphics_handler.getWindow();

	Bitboard board;

	board.loadFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR");

	while (window->isOpen())
	{
		sf::Event event;
		while (window->pollEvent(event))
		{
			graphics_handler.handleInput(event, board);
		}
		
		graphics_handler.clear();

		graphics_handler.drawSquares(board);
		graphics_handler.drawPieces(board);
		graphics_handler.drawValidPositions(board, graphics_handler.getSelectedSquare());

		graphics_handler.display();
	}
}