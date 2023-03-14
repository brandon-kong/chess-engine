return {
    pieces = {
        'bP', 'bR', 'bN', 'bB', 'bQ', 'bK',
        'wP', 'wR', 'wN', 'wB', 'wQ', 'wK'
    },

    icons = {
        wP = 'rbxassetid://12705284280',
        wR = 'rbxassetid://12705040502',
        wN = 'rbxassetid://12582721685',
        wB = 'rbxassetid://12705010496',
        wQ = 'rbxassetid://12705266883',
        wK = 'rbxassetid://12705276436',

        bP = 'rbxassetid://12705282472',
        bR = 'rbxassetid://12705043688',
        bN = 'rbxassetid://12593930998',
        bB = 'rbxassetid://12779066180',
        bQ = 'rbxassetid://12705264073',
        bK = 'rbxassetid://12705274158'
    },

    dimensions = 8, -- [8 x 8 board]

    colors = {
        light = Color3.fromRGB(255, 215, 53),
        dark = Color3.fromRGB(179, 150, 36),

        valid_light = Color3.fromRGB(49, 223, 72),
        valid_dark = Color3.fromRGB(35, 155, 51),

        take_light = Color3.fromRGB(255, 0, 0),
        take_dark = Color3.fromRGB(179, 0, 0),
    },
}