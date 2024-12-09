INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib


;-----------------------------------------------
; Program Info
; Program Name: BlackJack.asm
; Date made: 12/7/2024
; Description: This program is a clone of a simple BlackJack game. The goal of this game is defined by the rules listed in one of the strings below in the data section.
; This program will deal cards to a dealer and a player and the player will attempt to win. This program handles dealinfg cards and all other logic needed.
; ----------------------------------------------


.data
                                                    ; Card names are all 3 bytes. The ones with only 2 characters have an extra space.
card_deck  db "2C  ", "3C  ", "4C  ", "5C  ", "6C  ", "7C  ", "8C  ", "9C  ", "10C ", "JC  ", "QC  ", "KC  ", "AC  "
           db "2D  ", "3D  ", "4D  ", "5D  ", "6D  ", "7D  ", "8D  ", "9D  ", "10D ", "JD  ", "QD  ", "KD  ", "AD  "
           db "2H  ", "3H  ", "4H  ", "5H  ", "6H  ", "7H  ", "8H  ", "9H  ", "10H ", "JH  ", "QH  ", "KH  ", "AH  "
           db "2S  ", "3S  ", "4S  ", "5S  ", "6S  ", "7S  ", "8S  ", "9S  ", "10S ", "JS  ", "QS  ", "KS  ", "AS  "

                                                    ; This value deck holds all of the card values. 
                                                    ; It will be randomized each game
                                                    ; Only 1 deck however. 
value_deck db 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11
            db 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11
            db 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11
            db 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11

card_size EQU 4                                     ; Each card is 4 bytes long

total_cards EQU 52                                  ; Total cards used (decks * 52 cards)
temp_buffer db card_size+1 DUP(?)                   ; This is a temp buffer for printing the card names. 
deck_index DWORD 51                                 ; Tracks the top of the shuffled deck

; ----------- Player Data ----------------
player_values db 5 DUP(0)
player_cards db card_size*5+1 DUP(?)                ; max of 5 cards. Using 5-card charlie rule. If you draw 5 cards you automatically win. 
player_index DWORD 0
player_total DWORD 0
; ----------- Dealer Data ----------------
dealer_values db 5 DUP(0)
dealer_cards db card_size*5+1 DUP(?)
dealer_index DWORD 0
dealer_total DWORD 0
show_hidden_card DWORD 0                            ; Flag to show hidden card

; ----------------- STRINGS --------------------
welcome BYTE "Welcome to BlackJack!",0
rules BYTE "--------------------------------------------------------- RULES -----------------------------------------------------", 10, 13
      BYTE "1. The goal of the game is to get closer to 21 points than the dealer without going over 21.", 10, 13
      BYTE "2. If you or the dealer exceed 21 points, the one who goes over busts and loses.", 10, 13
      BYTE "3. Getting exactly 21 (a Blackjack) results in an automatic win unless the dealer also has 21, which then is a tie.", 10, 13
      BYTE "4. Once you choose to stand, you cannot draw any more cards and the dealer will reveal their hidden card.", 10, 13
      BYTE "5. The dealer draws cards until they have 17 or more points.", 10, 13
      BYTE "6. Both you and the dealer start with two cards ; one of the dealer’s cards is hidden until you stand.", 10, 13
      BYTE "Cards are denoted with the suit as the first character, and the number as their last 2 characters. ", 10, 13
      BYTE "For example: AS is Ace of Spades, 8H is Eight of Hearts, QC is Queen of Clubs, and so on, continued for all cards.", 10, 13
      BYTE "---------------------------------------------------------------------------------------------------------------------",0

line BYTE  "---------------------------------------------------------------------------------------------------------------------",0
hit_option BYTE "  Hit (1) ",0
stand_option BYTE " Stand (2) ",0
input_char BYTE " ", 0
dealt BYTE "You have been dealt an: ", 0
invalid_input BYTE "Invalid option.",0
player_hand_string BYTE "Player Hand: ",0
player_total_string BYTE "Player Total: ", 0
player_bust_string BYTE "You busted!. Better luck next time!", 0
dealer_bust_string BYTE "Dealer busted!. You won!", 0
player_blackjack_string BYTE "Blackjack!. You won!",0
dealer_blackjack_string BYTE "Dealer Got a Blackjack! You Lose!",0
dealer_hand_string BYTE "Dealer Hand: ",0
dealer_total_string BYTE "Dealer Total: ", 0
tie_string BYTE "Push! (Tie) You and the Dealer have the same card values!", 0
dealer_won BYTE "Dealer Won!. Better luck next time!",0
player_won BYTE "You Won!!!",0
hit_string BYTE "You chose to Hit!", 0
stand_string BYTE "You chose to Stand!", 0
repeat_string			BYTE "Would you like to play again? (y/n)" ,0
exit_string				BYTE "Exiting program.",0
mystery_card BYTE "??",0

.code
main PROC

    main_prog:
        CALL Randomize                                      ; Randomize the number generator
        CALL Game                                           ; call the game procedure to start the game
        CALL Crlf
        CALL Crlf

        CALL repeat_program									; This will do the repeat program procedure and get the user input
	    CMP EAX, 0											; If the user wants to exit the program jump to end_program
	    JE end_program

	    JMP main_prog

    RET
main ENDP

;---------------------------------------------------------------------------------
; This procedure prints the repeat_string prompt, and asks the the user if they want to repeat the program
; If they enter 'y' or 'Y', the program will repeat. Else, it will end the program
; Output: EAX = 1 (Repeat the program)
; Output: EAX = 0 (Exit the program)
;---------------------------------------------------------------------------------
repeat_program PROC
    MOV EAX, yellow+(blue*16)
    CALL SetTextColor


	MOV EDX, OFFSET repeat_string
	CALL WriteString

    MOV EAX, white+(black*16)
    CALL SetTextColor

	CALL ReadChar											; read char (y or Y to restart, other characters will end it)
	CALL WriteChar											; echo char back on screen so its visible. Irvine does not echo by default.

	CALL Crlf

															; logic to check if char is Y or y, otherwise exit
	CMP AL, 59h												; capital Y in hex. Checking if AL == Y
	JE set_repeat											; jump if equals to main_loop since we are restarting
	CMP AL, 79h												; lowercase y in hex.  Checking if AL == y
	JE set_repeat											; jump if equals to main_loop since we are restarting
															; else exit
	MOV EAX, 0												; Mov 0 into EAX showing the user wants to exit
	RET

	set_repeat:												; Move 1 into EAX meaning the user wants to repeat
		MOV EAX, 1
		RET

repeat_program ENDP

Game PROC                                                   ; main game procedure for handling all of the logic
    CALL Clrscr
    CALL ResetData
    CALL ShuffleDeck
    CALL DealInitialCards                                   ; Reset all data, shuffle cards, and deal the 4 initial cards

    MOV EDX, OFFSET welcome
    CALL WriteString
    CALL Crlf
    MOV EDX, OFFSET rules
    CALL WriteString
    CALL Crlf
    CALL Crlf                                               ; print the welcome message and rules

    CALL DisplayPlayerHand
    CALL Crlf
    CALL DisplayDealerHand
    CALL Crlf                                               ; display the player and dealer hand

    MOV EAX, player_total
    CMP EAX, 21
    JE player_blackjack




input:
    MOV EAX, white+(green*16)                               ; color the text green for the hit
    CALL SetTextColor

    MOV EDX, OFFSET hit_option
    CALL WriteString
    
    MOV EAX, white+(red*16)
    CALL SetTextColor

    MOV EDX, OFFSET stand_option
    CALL WriteString

    MOV EAX, white+(black*16)
    CALL SetTextColor

    CALL Crlf
    CALL ReadChar
    CALL Crlf

    SUB AL, '0'                                             ; subtract the char 0 so it becomes a number

    CMP AL, 1                                               ; if they press 1, hit
    JE hit

    CMP AL, 2                                               ; if they press 2, stand
    JE stand

    MOV EDX, OFFSET invalid_input                           ; else invalid input and restart taking in input
    CALL WriteString
    CALL Crlf
    JMP input

hit:                                                        ; hit loop
    MOV EDX, OFFSET hit_string
    CALL WriteString
    CALL Crlf
    CALL DealPlayerCard                                     ; deal the player a card

    CALL Crlf
    MOV EDX, OFFSET line
    CALL WriteString
    CALL Crlf

after_hit:                                                  ; after the player hits we check values and their hand
    CALL DisplayPlayerHand                                  ; display hands
    CALL Crlf
    CALL DisplayDealerHand
    CALL Crlf

    MOV EAX, player_total                                   ; move the player total into EAX for comparisn

    CMP EAX, 21
    JE player_blackjack                                     ; If player reaches exactly 21, it's a blackjack.

    CMP EAX, 21
    JA player_bust                                          ; If player goes over 21, player busts.

                                                            ; If under 21, prompt again for action
    JMP input

stand:                                                      ; if the user stands jump here
    CALL Crlf
    MOV EDX, OFFSET line
    CALL WriteString
    CALL Crlf

    MOV EDX, OFFSET stand_string
    CALL WriteString
    CALL Crlf

                                                            ; Reveal dealer's hidden card
    MOV show_hidden_card, 1                                 ; set the dealers flag to show the hidden card
    CALL DisplayDealerHand

                                                            ; Now dealer draws until total >= 17 or bust
    JMP dealer_turn

dealer_turn:
    MOV EAX, player_total
    MOV EBX, dealer_total

    CMP EBX, 21
    JE dealer_decision                                      ; If dealer hits exactly 21, check against player.

    CMP EBX, 21
    JA dealer_bust                                          ; If dealer goes over 21, dealer busts => player wins.

    CMP EBX, 17
    JL dealer_draw                                          ; If dealer < 17, must keep drawing.

                                                            ; If dealer >= 17 and <= 21, compare totals
    JMP dealer_decision

dealer_draw:                                                ; if the dealer draws display hands and jump to dealers turn
    CALL DealDealerCard
    CALL DisplayDealerHand

    JMP dealer_turn

dealer_bust:                
                                                            ; Dealer busts => player wins
    MOV EDX, OFFSET dealer_bust_string
    CALL WriteString
    RET

dealer_decision:
                                                            ; Compare totals now that dealer is done drawing
                                                            ; EAX = player_total, EBX = dealer_total
    MOV EAX, player_total
    MOV EBX, dealer_total

                                                            ; Check for blackjacks (21)
    CMP EAX, 21
    JE player_blackjack_check
    CMP EBX, 21
    JE dealer_blackjack_check
                                                            ; If no blackjack, compare values
    CMP EAX, EBX
    JE tie_push
    CMP EAX, EBX
    JG player_win
    JL dealer_win

player_blackjack_check:
                                                            ; If player has 21 and dealer doesn't, player wins
    CMP EBX, 21
    JE tie_push                                             ; If both have 21, it's a tie
    JMP player_blackjack

dealer_blackjack_check:
                                                            ; If dealer has 21 and player doesn't
    CMP EAX, 21
    JE tie_push                                             ; Tie if player also has 21
    JMP dealer_blackjack

player_bust:                                                ; if the player busts, print msg
    MOV EDX, OFFSET player_bust_string
    CALL WriteString
    RET

tie_push:                                                   ; if they tie, or push print msg
    MOV EDX, OFFSET tie_string
    CALL WriteString
    RET

player_win:                                                 ; if the player wins, print msg
    MOV EDX, OFFSET player_won
    CALL WriteString
    RET

dealer_win:                                                 ; if the dealer wins, print msg
    MOV EDX, OFFSET dealer_won
    CALL WriteString
    RET

player_blackjack:                                           ; if the player gets 21 (blackjack), print msg
    MOV EDX, OFFSET player_blackjack_string
    CALL WriteString
    RET

dealer_blackjack:                                           ; if the dealer gets 21 (blackjack), print msg
    MOV EDX, OFFSET dealer_blackjack_string
    CALL WriteString
    RET

Game ENDP

;----------------------------------
; This procedure displays the dealers hand. If the dealer has the show_hidden_card not set, it will only show 1 card.
; Else it will show all cards and the values. 
; It will print the total in red for the dealer
;----------------------------------
DisplayDealerHand PROC
    MOV dealer_total, 0                                     ; move 0 into the dealer total to reset it
    MOV ECX, dealer_index

    MOV EDX, OFFSET dealer_hand_string
    CALL WriteString

    MOV EAX, show_hidden_card                               ; move the hidden flag into EAX
    CMP EAX, 0                                              ; compare eax to 0 to see if the flag is set
    JE hidden_card                                          ; if set, show the hidden card
    JMP skip_hidden                                         ; else show all the cards


    hidden_card:
        MOV EBX, OFFSET dealer_cards
        MOV EAX, 0                                          ; print the first card
        CALL PrintCard
        MOV EDX, OFFSET mystery_card                        ; move the "??" string into EDX for the second card
        CALL WriteString
        CALL Crlf

        MOVZX EAX, [dealer_values]                          ; move the first card value into EAX
        MOV EDX, OFFSET dealer_total_string
        CALL WriteString

        MOV EAX, red+(black*16)                             ; print the total in red
        CALL SetTextColor
        CALL WriteDec
        MOV EAX, white+(black*16)
        CALL SetTextColor
        RET

    skip_hidden:
    MOV ESI, 0                                              ; Amount of aces in hand
    value_loop:
        CMP ECX, 0                                          ; check the amount of cards in the hand
        JE final_calculation                                ; if the cards is zero, jump to the end

        
        MOV EAX, ECX                                        ; move the card index into EAX
        DEC EAX                                             ; decrement the card index so we can access values

        MOV EBX, OFFSET dealer_cards                        ; move dealer cards into EBX so we can print the card
        CALL PrintCard

        MOVZX EDX, [dealer_values + EAX]                    ; move the dealer value at the index into EDX

        CMP EDX, 11                                         ; compare EDX to 11 to see if its an ACE
        JE ace_match                                        ; if it is an ace, jump to ace_match

                                                            ; else:
        MOV EBX, dealer_total                               ; move the dealer total into EBX
        ADD EBX, EDX                                        ; add the card value to the total
        MOV dealer_total, EBX                               ; move the card val+ total back into total

        DEC ECX                                             ; decrement ECX since we are going down the deck
        MOV EBX, dealer_total                               ; move the dealer total into EBX
        JMP value_loop                                      ; jump to the value loop again
    
    skip_ace:                                               ; skip  the ace and count it as 1
        INC dealer_total
        DEC ESI                                             ; decrement the amount of aces
        JMP final_calculation

    final_calculation:
        CMP ESI, 0                                          ; check if there are aces
        JE done                                             ; if there arent, we are done

        CMP ESI, 2                                          ; if there are multiple aces, jump to the skip loop
        JGE skip_ace

        MOV EAX, dealer_total                               ; move the dealer_total into EAX
        ADD EAX, 11                                         ; add 11, and compare to 21
        CMP EAX, 21
        JG skip_ace                                         ; if its greater than 21 skip the ace and count as 1
        
        MOV dealer_total, EAX                               ; once done, move the total back into dealer_total
        JMP done

    ace_match:                                              ; if its an ace, increase the ace counter in ESI
        INC ESI
        DEC ECX                                             ; decrease the deck index
        JMP value_loop                                      ; continue reading the hand

     done:
        CALL Crlf
        MOV EDX, OFFSET dealer_total_string
        CALL WriteString

        MOV EAX, red+(black*16)                             ; once we are done, print all of the values in red
        CALL SetTextColor
        MOV EAX, dealer_total
        CALL WriteDec
        MOV EAX, white+(black*16)
        CALL SetTextColor
        CALL Crlf

        RET 
DisplayDealerHand ENDP

; -----------------------------------------
; This peocedure prints the players hand. 
; -----------------------------------------
DisplayPlayerHand PROC
    MOV player_total, 0                                     ; move 0 into the player total to reset it
    MOV ECX, player_index                                   ; move the amount of cards into ECX

    MOV EDX, OFFSET player_hand_string
    CALL WriteString

    MOV ESI, 0                                              ; Amount of aces in players hand
    value_loop:
        CMP ECX, 0                                          ; compare the amount of cards to 0
        JE final_calculation                                ; if we have read all of the deck, were done

        
        MOV EAX, ECX                                        ; move the amount of cards into EAX
        DEC EAX                                             ; decrement so we can access values

        MOV EBX, OFFSET player_cards                        ; move the player_cards into EBX so I can print the card
        CALL PrintCard

        MOVZX EDX, [player_values + EAX]                    ; move the player_value into EDX from the player_values deck

        CMP EDX, 11                                         ; compare the card to an ace and jump to ace_match if it matches
        JE ace_match

        MOV EBX, player_total                               ; move the player_total into EBX
        ADD EBX, EDX                                        ; add card value to the total value
        MOV player_total, EBX                               ; move the total value + card value back into the total

        DEC ECX                                             ; decrease the deck index
        MOV EBX, player_total                               ; move the player total back into EBX
        JMP value_loop                                      ; repeat to read the rest of the cards
    
    skip_ace:                                               ; count aces as a value of 1
        INC player_total
        DEC ESI
        JMP final_calculation

    final_calculation:                                      ; final calculation to print all the values
        CMP ESI, 0                                          ; if there are 0 aces, we are done
        JE done

        CMP ESI, 2                                          ; if there are multiple aces, we skip and count some as 1
        JGE skip_ace

        MOV EAX, player_total                               ; move the player total into EAX if we have only 1 ace
        ADD EAX, 11                                         ; add the ace to the player total
        CMP EAX, 21                                         ; check if it exceeds 21
        JG skip_ace                                         ; if it does count it as 1
        
        MOV player_total, EAX                               ; move the new total into player_total
        JMP done

    ace_match:                                              ; if there is an ace, increase the ace counter and continue
        INC ESI
        DEC ECX
        JMP value_loop

     done:                                                  ; if done, print the total value in green and format it
        CALL Crlf
        MOV EDX, OFFSET player_total_string
        CALL WriteString
        MOV EAX, green+(black*16)
        CALL SetTextColor
        MOV EAX, player_total
        CALL WriteDec
        MOV EAX, white+(black*16)
        CALL SetTextColor
        CALL Crlf

        RET 
DisplayPlayerHand ENDP

;--------------------------------------
; This procedure resets all of the data needed for the next game loop
;--------------------------------------
ResetData PROC
    MOV show_hidden_card, 0                                 ; change the flag to hide the hidden card for the next game
    MOV deck_index, 51                                      ; Reset the deck index back to 51

    XOR EAX, EAX                                            ; Set the indexs both to 0
    MOV player_index, EAX
    MOV dealer_index, EAX

    MOV EDI, OFFSET player_values                           ; clear the player values. 5 bytes
    MOV ECX, 5
    XOR EAX, EAX
    REP STOSB                                               ; fill with 0 5 times

    MOV EDI, OFFSET player_cards                            ; clear the player cards
    MOV ECX, card_size*5+1                                  ; 5 * card_size + 1.
    XOR EAX, EAX
    REP STOSB                                               ; Fill 21 times with 0

                                                            ; same process with dealer values below. 
    MOV EDI, OFFSET dealer_values
    MOV ECX, 5
    XOR EAX, EAX
    REP STOSB

    MOV EDI, OFFSET dealer_cards
    MOV ECX, card_size*5+1
    XOR EAX, EAX
    REP STOSB

    RET
ResetData ENDP

;---------------------------------------
; This procedure just calls the 2 other procedures to deal the player and the dealer their cards.
;---------------------------------------
DealInitialCards PROC
    ;  -------- Player Cards ----------
    CALL DealPlayerCard
    CALL DealPlayerCard
    ; --------- Dealer Cards ----------
    CALL DealDealerCard
    CALL DealDealerCard

    RET
DealInitialCards ENDP

;---------------------------------------
; This procedure deals the player a card and adds it to the player value deck and player card deck
;---------------------------------------
DealPlayerCard PROC
    ; ------ VALUE DECK ----------
    MOV EAX, deck_index                                 ; move the deck index into EAX
    MOVZX EAX, [value_deck+EAX]                         ; find the index of the card from the current deck
    MOV ECX, player_index                               ; move the current player index into ECX
    MOV [player_values+ECX], AL                         ; put the popped value from the deck into the player_values at index

    ; ------- CARD DECK ----------
    MOV EAX, deck_index                                 ; move the global deck_index into EAX
    IMUL EAX, card_size                                 ; multiply by card size for the card offset

    MOV ESI, OFFSET card_deck                           ; move the card deck memory address into ESI
    ADD ESI, EAX                                        ; add the offset to the card deck address

    MOV EAX, player_index                               ; move the player index into EAX
    IMUL EAX, card_size                                 ; multiply the player index by the card size
    MOV EDI, OFFSET player_cards                        ; add the offset to the player_cards address
    ADD EDI, EAX                            
    
    MOV ECX, card_size                                  ; move the card size into ECX (4)
    REP MOVSB                                           ; move the 4 bytes into the destination player_cards

    INC player_index                                    ; increment the player_index since the hand increased
    DEC deck_index                                      ; decrement the stack index
    RET
DealPlayerCard ENDP

;---------------------------------------
; This procedure deals the dealer a card and adds it to the dealer value deck and dealer card deck
;---------------------------------------
DealDealerCard PROC
    ; ------ VALUE DECK ----------
    MOV EAX, deck_index                                 ; move the deck index into EAX
    MOVZX EAX, [value_deck+EAX]                         ; find the index of the card from the current deck
    MOV ECX, dealer_index                               ; move the current player index into ECX
    MOV [dealer_values+ECX], AL                         ; put the popped value from the deck into the dealer_values at index

    ; ------- CARD DECK ----------
    MOV EAX, deck_index                                 ; move the global deck_index into EAX
    IMUL EAX, card_size                                 ; multiply by card size for the card offset

    MOV ESI, OFFSET card_deck                           ; move the card deck memory address into ESI
    ADD ESI, EAX                                        ; add the offset to the card deck address

    MOV EAX, dealer_index                               ; move the dealer_index into EAX
    IMUL EAX, card_size                                 ; multiply the player index by the card size
    MOV EDI, OFFSET dealer_cards                        ; add the offset to the dealer_cards address
    ADD EDI, EAX                            
    
    MOV ECX, card_size                                  ; move the card size into ECX (4)
    REP MOVSB                                           ; move the 4 bytes into the destination player_cards

    INC dealer_index                                    ; increment the dealer_index since the hand increased
    DEC deck_index                                      ; decrement the stack index
    RET
DealDealerCard ENDP

;-------------------------
; Using the Fisher-Yates algorithm (cool and easy algorithm) this procedure randomizes and shuffles the 2 decks of values and cards. 
;-------------------------
ShuffleDeck PROC
    MOV ECX, 52
    shuffle_loop:
        MOV EBX, ECX                                    ; Store the current index of the element
        DEC EBX
                                                        ; shuffle the numers first
        MOV EAX, ECX
        CALL RandomRange                                ; ( 0 to ECX = 0 to EBX) non inclusive random range
                                                        ; random number now inside EAX

        ;-----------------VALUE DECK--------------------------------------
        XOR EDX, EDX                                    ; clear upper value of EDX
        MOV DL, BYTE PTR [value_deck+EBX]               ; move number at index into DL
        MOV DH, BYTE PTR [value_deck+EAX]               ; move random numver into DH

        MOV [value_deck+EBX], DH                        ; Swap the 2 values at the indexes
        MOV [value_deck+EAX], DL
        ;-----------------------------------------------------------------


        ;----------------CARD DECK----------------------------------------
        PUSH ECX                                        ; Store ECX in stack since I use it for moving data

        MOV ESI, OFFSET card_deck                       ; move the address of the card_deck into ESI

        IMUL EBX, card_size                             ; multiply the current index * 4 for the card index
        ADD ESI, EBX                                    ; add the offset to the card_deck offset
        MOV EDI, OFFSET temp_buffer                     ; move the address of the temp_buffer into EDI for a median
        MOV ECX, card_size                              ; number of bytes to move (4)
        REP MOVSB                                       ; repeat move the bytes 4 times into temp_buffer

        MOV ESI, OFFSET card_deck                       ; store the address of the card_deck again to reset it
        IMUL EAX, card_size                             ; find index of random card
        ADD ESI, EAX                                    ; add the offset to the card_deck
        MOV EDI, OFFSET card_deck                       ; move the card_deck source into EDI
        ADD EDI, EBX                                    ; Add the current element to the card_deck
        MOV ECX, card_size                              ; move 4 into ECX
        REP MOVSB                                       ; this will move the random card into the current card index

        MOV ESI, OFFSET temp_buffer                     ; move the index card into ESI
        MOV EDI, OFFSET card_deck                       ; move the card deck into EDI
        ADD EDI, EAX                                    ; add the offset of the random card to the deck
        MOV ECX, card_size                              ; move 4 into ECX
        REP MOVSB                                       ; copy the temp card into the random card spot
        ;-----------------------------------------------------------------
        POP ECX
        loop shuffle_loop
    RET
ShuffleDeck ENDP

;------------------------------------------------------------
; This procedure will print a single card from the deck 
; Input: EAX as the card index
; Will print the card onto the screen 
; EBX: Address of where to print the card from. Eg: card_deck, player_cards, dealer_cards
;------------------------------------------------------------
PrintCard PROC USES EBX ESI EDI ECX
    MOV ESI, EBX                                    ; Address of the deck
    MOV ECX, EAX                                    ; move the card index into ecx
    IMUL ECX, card_size                             ; find the actual byte offset of the card
    ADD ESI, ECX                                    ; add the offset to the card_deck address

    LEA EDI, temp_buffer                            ; Destination: temp_buffer
    MOV ECX, card_size                              ; number of bytes (4)
    REP MOVSB                                       ; move the 4 bytes into the buffer
    MOV BYTE PTR [temp_buffer + card_size], 0


    MOV EDX, OFFSET temp_buffer
    CALL WriteString

    RET
PrintCard ENDP

end_program:
    MOV EDX, OFFSET exit_string
    CALL WriteString
    CALL Crlf
    RET

END main
