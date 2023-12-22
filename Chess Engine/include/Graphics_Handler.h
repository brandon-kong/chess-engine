#pragma once

#ifndef GRAPHICS_HANDLER_H
#define GRAPHICS_HANDLER_H

#include "Bitboard.h"
#include <SFML/Graphics.hpp>


const static float SQUARE_SIZE = 100.0f;
const static float WINDOW_WIDTH = BOARD_SIZE * SQUARE_SIZE;
const static float WINDOW_HEIGHT = BOARD_SIZE * SQUARE_SIZE;
      
static std::string WINDOW_TITLE = "Chess Engine";

class Graphics_Handler
{
public:
	Graphics_Handler();
	~Graphics_Handler();

	sf::RenderWindow* getWindow() const;

	// Clear the window 
	void clear();

	// Update the window
	void update();

	// Display the window
	void display();

	// Draw the squares of the board
	void drawSquares(const Bitboard& board);
	void drawPieces(const Bitboard& board);

private:
	sf::RenderWindow* window;
};

#endif