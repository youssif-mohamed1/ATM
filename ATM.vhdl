library ieee;
use ieee.std_logic_1164.all;

entity ATM is                                                                                                                                                
  port (
    button1, button2, button3, back, cancel, reset, clk , receipt_check, limit, with_money, divisble_5, ava_cash, ask_check:in std_logic;
    reciept, money_return, Balance_show                               : out std_logic;
    cash_reader                           : in std_logic;
    valid_pass:in std_logic_vector(2 downto 0);
    valid, balance_check:in std_logic
  );
end ATM;

architecture behaviour of ATM is
  type state is (Start, ask, Enter_Card, Enter_Pass, Enter_Money, Enter_Cash, With_Card_menu, Balance, withdraw, deposit, print_reciept, Card_dispence, Enter_Phone, WIthout_Card_Menu, return_money, dispense_cash, release_money);
  signal prs, nxt : state;

begin

  seq : process (clk, reset)
  begin
    if reset = '1' then
      prs <= Start;
    else
      if (rising_edge(clk)) then
        prs <= nxt;
      end if;
    end if;
  end process seq;

  comb : process (cancel, back, button1, button2, button3, reset, clk, receipt_check, limit, with_money, divisble_5, ava_cash, cash_reader, valid_pass, valid, balance_check)
      variable withdrawn_done: std_logic := '0';
      variable pass_flag: std_logic := '0';
      variable reciept_check: std_logic := '0';

  begin
    if prs = start then     -- Start State
        Balance_show <= '0';
        reciept <= '0';
        money_return <= '0';
        withdrawn_done:='0';       
      if button1 = '1' then -- with card
        nxt <= Enter_Card;
      else
        nxt <= Start;
      end if;

    elsif prs = Enter_Card then -- Enter Card State
        if valid='1' then
            nxt<=Enter_Pass;
        else
            nxt<= Card_dispence;    
        end if;
        
    elsif prs= Card_dispence then --Card dispense State
        if withdrawn_done='1' then 
            nxt<=dispense_cash;
        else 
            nxt<=Start;    
        end if;
    
    elsif prs=dispense_cash then
        nxt<=Start;

    elsif prs=Enter_Pass then -- Entering password
      if cancel = '1' then
        nxt <= Card_dispence;
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
          else 
          nxt<=Card_dispence;
        end if;
      end if;         
    elsif prs = with_Card_menu then -- Menu State
        if cancel = '1' then
          nxt <= Card_dispence;
        elsif button1 = '1' and button2 = '0' and button3 = '0' then -- balance
            nxt <= Balance;
        elsif button2 = '1' and button1 = '0' and button3 = '0' then -- withdraw
            nxt <= withdraw;
        elsif button3 = '1' and button1 = '0' and button2 = '0' then -- deposite
            nxt <= deposit;
        else 
            nxt <= with_Card_menu;
        end if;

    
    elsif prs = Balance then -- Check Balance State
          Balance_show <= '1';
          if back = '1' then 
            nxt <= With_Card_menu;
          elsif cancel = '1' then
            nxt <= Card_dispence;
          elsif receipt_check = '1' then
            reciept<='1';
            nxt<=Card_dispence; 
          else
            reciept <= '0';
            nxt<=card_dispence;
          end if;  
    
    elsif prs = withdraw then -- Withdraw State
        if back = '1' then 
          nxt <= With_Card_menu;
        elsif cancel = '1' then
          nxt <= Card_dispence;
        elsif limit='1' then
          nxt<=card_dispence;
        else
          nxt<=Enter_Money;
        end if;

    elsif prs = Enter_Money then -- Enter Money State in withdrawing
        if cancel = '1' then
          nxt <= Card_dispence;
        elsif with_money='1' and divisble_5='1' and ava_cash='1' and balance_check='1' then
          nxt <= print_reciept;
        else
          nxt <= Enter_Money;
        end if;

    elsif prs = print_reciept then --Print Receipt & Card Dispenese State
      if receipt_check='1' then
        reciept<='1';
        nxt<=Card_dispence;
      else
        reciept<='0';
        nxt<=card_dispence;
      end if;
      
    elsif prs = deposit then -- Deposit State
        if back = '1' then 
          nxt <= With_Card_menu;
        elsif cancel = '1' then 
          nxt <= Card_dispence;
        else
          nxt<=Enter_Cash;
      end if;
    elsif prs = Enter_Cash then -- Enter_Cash State in Deposit
      if cancel = '1' then 
        nxt <= Card_dispence;
      elsif cash_reader='1' or divisble_5 = '0' then
          nxt <= release_money;
        else
          nxt<= ask;
      end if;

    elsif prs = release_money then -- release State : return bad money
      money_return<='1'; -- bad money output
      nxt<=ask;
      
    elsif prs = ask then -- ASK State after Deposit
      if ask_check ='1' then
        nxt <= print_reciept;
      else 
        nxt <= return_money;
      end if;
    
    elsif prs= return_money then -- return_money State: if user cancel the deposit process 
        money_return<='1';
        nxt<=Card_dispence;
    end if;
    
    end process comb;
end behaviour;

