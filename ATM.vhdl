library ieee;
use ieee.std_logic_1164.all;

entity ATM is                                                                                                                                                
  port (
    button1, button2, button3, reset, clk , receipt_check, limit, with_money, divisble_5, ava_cash, ask_check:in std_logic;
    reciept, money_return                               : out std_logic;
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

  comb : process (button1, button2, button3, reset, clk , receipt_check, limit,with_money,divisble_5,ava_cash,cash_reader,valid_pass,valid,balance_check)
      variable withdrawn_done: std_logic;
      variable pass_flag: std_logic;
      variable reciept_check: std_logic;

  begin
    if prs = start then     -- Start State
        withdrawn_done:='0';       
      if button1 = '1' then -- with card
        nxt <= Enter_Card;
      elsif button2 = '1' then -- without card
        nxt <= Enter_Phone;
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
    
    elsif prs = with_Card_menu then -- Menu State

        if button1 = '1' then -- balance
            nxt <= Balance;
        elsif button2 = '1' then -- withdraw
            nxt <= withdraw;
        elsif button3 = '1' then -- deposite
            nxt <= deposit;
        else 
            nxt <= with_Card_menu;
        end if;

    
    elsif prs = Balance then -- Check Balance State
          if receipt_check = '1' then
            reciept<='1';
            nxt<=Card_dispence;
          else
            reciept <= '0';
            nxt<=card_dispence;
          end if;  
    
    elsif prs = withdraw then -- Withdraw State
        if limit='1' then
          nxt<=card_dispence;
        else
          nxt<=Enter_Money;
        end if;

    elsif prs = Enter_Money then -- Enter Money State in withdrawing

        if with_money='1' and divisble_5='1' and ava_cash='1' and balance_check='1' then
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
      nxt<=Enter_Cash;

    elsif prs = Enter_Cash then -- Enter_Cash State in Deposit
      if cash_reader='1' or divisble_5 = '0' then
        nxt<= return_money;
      else
        nxt <= ask;
      end if;

    elsif prs = release_money then -- release State : return bad money
      money_return<='1'; -- bad money output
      nxt<=ask;
      
    elsif prs = ask then -- ASK State after Deposit
      if ask_check ='1' then
        nxt<=print_reciept;
      else 
        nxt<= return_money;
      end if;
    
    elsif prs= return_money then -- return_money State: if user cancel the deposit process 
        money_return<='1';
        nxt<=Card_dispence;
    end if;
    
    end process comb;
end behaviour;

