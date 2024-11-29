library ieee;
use ieee.std_logic_1164.all;

entity ATM is                                                                                                                                                
  port (
    button1, button2, button3, back, cancel, reset, clk , receipt_check, limit, with_money, divisble_5, ava_cash, ask_check:in std_logic;
    reciept, money_return, Balance_show, cash_show                            : out std_logic;
    cash_reader                           : in std_logic;
    valid_pass:in std_logic_vector(2 downto 0);
    valid, balance_check:in std_logic;
    prs_o, nxt_o: inout STD_LOGIC_VECTOR(4 downto 0)
  );
end ATM;

architecture behaviour of ATM is
  type state is (
    Start, -- 0
    ask, -- 1
    Enter_Card, -- 2
    Enter_Pass, -- 3
    Enter_Money, -- 4
    Enter_Cash, -- 5
    With_Card_menu, -- 6
    Balance, -- 7
    withdraw, -- 8
    deposit, -- 9
    print_reciept, -- 10
    Card_dispence, -- 11
    Enter_Phone, -- 12
    WIthout_Card_Menu, -- 13
    return_money, -- 14
    dispense_cash, -- 15
    release_money); -- 16
  signal prs, nxt : state;

begin
  seq : process (clk, reset)
  begin
    if reset = '1' then
      prs <= Start;
    else
      if (rising_edge(clk)) then
        prs <= nxt;
        prs_o <= nxt_o;
      end if;
    end if;
  end process seq;

  comb : process (cancel, back, button1, button2, button3, reset, clk, receipt_check, limit, with_money, divisble_5, ava_cash, cash_reader, valid_pass, valid, balance_check)
      variable withdrawn_done: std_logic := '0';
      variable pass_flag: std_logic := '0';

  begin
    if prs = start then     -- Start State
        Balance_show <= '0';
        reciept <= '0';
        cash_show<='0';
        money_return <= '0';
        withdrawn_done:='0';       
      if button1 = '1' then -- with card
        nxt <= Enter_Card;
        nxt_o <= "00010";
      else
        nxt <= Start;
        nxt_o<="00000";
      end if;

    elsif prs = Enter_Card then -- Enter Card State
        if valid='1' then
            nxt<=Enter_Pass;
            nxt_o<="00011";
        else
            nxt<= Card_dispence;
            nxt_o<="01011";    
        end if;
        
    elsif prs= Card_dispence then --Card dispense State
        if withdrawn_done='1' then 
            nxt<=dispense_cash;
            nxt_o <= "01111";
        else 
            nxt<=Start;
            nxt_o <= "00000";    
        end if;
    
    elsif prs=dispense_cash then
        cash_show<='1';
        nxt<=Start;
        nxt_o <= "00000";  

    elsif prs=Enter_Pass then -- Entering password
      if cancel = '1' then
        nxt <= Card_dispence;
        nxt_o<="01011";
      else
        pass_flag:='0';
          L: for i in 0 to 2 Loop
              if valid_pass(i)='1' then
                pass_flag:='1';
                exit;      
              end if;   
          end  loop L;

        if pass_flag='1' then 
          nxt<= With_Card_menu;
          nxt_o <= "00110";
          else 
          nxt<=Card_dispence;
          nxt_o<="01011";
        end if;
      end if;         
    elsif prs = with_Card_menu then -- Menu State
        if cancel = '1' then
          nxt <= Card_dispence;
          nxt_o<="01011";
        elsif button1 = '1' and button2 = '0' and button3 = '0' then -- balance
            nxt <= Balance;
            nxt_o <= "00111";
        elsif button2 = '1' and button1 = '0' and button3 = '0' then -- withdraw
            nxt <= withdraw;
            nxt_o <= "01000";
        elsif button3 = '1' and button1 = '0' and button2 = '0' then -- deposite
            nxt <= deposit;
            nxt_o <= "01001";
        else 
            nxt <= with_Card_menu;
            nxt_o <= "00110";
        end if;

    
    elsif prs = Balance then -- Check Balance State
          Balance_show <= '1';
          
          if back = '1' then 
            nxt <= With_Card_menu;
            nxt_o <= "00110";
          elsif cancel = '1' then
            nxt <= Card_dispence;
            nxt_o<="01011";
          elsif receipt_check = '1' then
            --reciept<='1';
            nxt<=print_reciept; 
            nxt_o<="01010";
          else
            reciept <= '0';
            nxt<=card_dispence;
            nxt_o<="01011";
          end if;  
    
    elsif prs = withdraw then -- Withdraw State
        if back = '1' then 
          nxt <= With_Card_menu;
          nxt_o <= "00110";
        elsif cancel = '1' then
          nxt <= Card_dispence;
          nxt_o<="01011";
        elsif limit='1' then
          nxt<=card_dispence;
          nxt_o<="01011";
        else
          nxt<=Enter_Money;
          nxt_o <= "00100";
          withdrawn_done := '1';
        end if;

    elsif prs = Enter_Money then -- Enter Money State in withdrawing
        if cancel = '1' then
          nxt <= Card_dispence;
          nxt_o<="01011";
        elsif with_money='1' and divisble_5='1' and ava_cash='1' and balance_check='1' then
          if receipt_check='1' then
            nxt <= print_reciept;
            nxt_o <= "01010";
          else 
            nxt <= Card_dispence;
            nxt_o<="01011";
          end if;
        else
          nxt <= Enter_Money;
          nxt_o <= "00100";
        end if;

    elsif prs = print_reciept then --Print Receipt & Card Dispenese State
        reciept<='1';
        nxt<=Card_dispence;
        nxt_o<="01011";
      end if;
      
    elsif prs = deposit then -- Deposit State
        if back = '1' then 
          nxt <= With_Card_menu;
          nxt_o <= "00110";
        elsif cancel = '1' then 
          nxt <= Card_dispence;
          nxt_o<="01011";
        else
          nxt<=Enter_Cash;
          nxt_o <= "00101";
      end if;

    elsif prs = Enter_Cash then -- Enter_Cash State in Deposit
      if cancel = '1' then 
        nxt <= Card_dispence;
        nxt_o<="01011";
      elsif cash_reader='1' or divisble_5 = '0' then
          nxt <= release_money;
          nxt_o <= "10000";
        else
          nxt<= ask;
          nxt_o <= "00001";
      end if;

    elsif prs = release_money then -- release State : return bad money
      money_return<='1'; -- bad money output
      nxt<=ask;
      nxt_o <= "00001";
      
    elsif prs = ask then -- ASK State after Deposit
      if ask_check ='1'and receipt_check ='1' then
        nxt <= print_reciept;
        nxt_o <= "01010";
      elsif ask_check ='1'and receipt_check ='0' then
        nxt<=Card_dispence;
        nxt_o<="01011";
      else 
        nxt <= return_money;
        nxt_o <= "01110";
      end if;
    
    elsif prs= return_money then -- return_money State: if user cancel the deposit process 
        money_return<='1';
        nxt<=Card_dispence;
        nxt_o<="01011";
    end if;
    end process comb;
end behaviour;

