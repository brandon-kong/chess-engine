#pragma once

#ifndef GRAPHICS_HANDLER_H
#define GRAPHICS_HANDLER_H

#include "Bitboard.h"
#include <SFML/Graphics.hpp>


const static float SQUARE_SIZE = 100.0f;
const static float WINDOW_WIDTH = BOARD_SIZE * SQUARE_SIZE;
const static float WINDOW_HEIGHT = BOARD_SIZE * SQUARE_SIZE;
      
static std::string WINDOW_TITLE = "Chess Engine";

const static sf::Color LIGHT_SQUARE_COLOR = sf::Color(232, 237, 249);
const static sf::Color DARK_SQUARE_COLOR = sf::Color(183, 192, 216);

const static sf::Color SELECTED_LIGHT_SQUARE_COLOR = sf::Color(177, 167, 252);
const static sf::Color SELECTED_DARK_SQUARE_COLOR = sf::Color(153, 144, 235);

const static sf::Color VALID_MOVE_COLOR = sf::Color(153, 144, 235);

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

	void handleInput(sf::Event event, const Bitboard board);

	// Draw the squares of the board
	void drawSquares(const Bitboard& board);
	void drawPieces(const Bitboard& board);
	void drawValidPositions(Bitboard board, int square);

	int getSelectedSquare() const;

private:
	sf::RenderWindow* window;
	int selectedSquare;
};

#endif