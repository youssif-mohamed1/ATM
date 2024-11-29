library ieee;
use ieee.std_logic_1164.all;

entity ATM_TB is
end ATM_TB;

architecture behavoiur of ATM_TB is 
    component ATM is
        port (
            button1, button2, button3, back, cancel, reset, clk , receipt_check, limit, with_money, divisble_5, ava_cash, ask_check:in std_logic;
            reciept, money_return, Balance_show, cash_show                            : out std_logic;
            cash_reader                           : in std_logic;
            valid_pass:in std_logic_vector(2 downto 0);
            valid, balance_check:in std_logic;
            prs_o, nxt_o: inout STD_LOGIC_VECTOR(4 downto 0)
          );
    end component;
    signal prs_o, nxt_o: std_logic_vector(4 downto 0);
    signal cash_show, valid, balance_check, cash_reader, button1, button2, button3, back, cancel, reset, clk , receipt_check, limit, with_money, divisble_5, ava_cash, ask_check: std_logic;
    signal valid_pass: std_logic_vector(2 downto 0);
    signal reciept, money_return, Balance_show: std_logic;
    begin
        port1: ATM port map(button1, button2, button3, back, cancel, reset, clk , receipt_check, limit, with_money, divisble_5, ava_cash, ask_check, reciept, money_return, Balance_show, cash_show, cash_reader, valid_pass, valid, balance_check, prs_o, nxt_o);
        -- generation of clock
        clk_process : PROCESS
        BEGIN
            l:for i in 0 to 400 loop
                if clk = '0' then 
                    clk <= '1';
                else 
                    clk <= '0';
                end if;
                WAIT FOR 5 ns;
            end loop l;
            wait;
        END PROCESS clk_process;

        comb : process
            begin
            reset <= '1'; -- reset
            WAIT FOR 10 ns;
            reset <= '0'; -- choose Enter card
            button1 <= '1';
            button2 <= '0';
            button3 <= '0';
            wait for 10 ns; -- valid card input
            valid <= '1';
            wait for 10 ns; -- valid pass input 
            valid_pass <= "100";
            wait for 10 ns; -- choose balance from card menu
            button1 <= '1';
            button2 <= '0';
            button3 <= '0';
            receipt_check <= '1';
            wait for 10 ns; -- want receipt
            wait for 10 ns; -- dispense
            wait for 10 ns; -- start
            WAIT FOR 10 ns;

            button1 <= '1';
            button2 <= '0';
            button3 <= '0';
            wait for 10 ns; -- valid card input
            valid <= '1';
            wait for 10 ns; -- valid pass input 
            valid_pass <= "100";
            wait for 10 ns;
            button1 <= '0';
            button2 <= '0';
            button3 <= '1';
            wait for 10 ns; -- deposit
            wait for 10 ns; -- enter cash
            cash_reader <= '0';
            divisble_5 <= '1';
            wait for 10 ns;
            ask_check <= '1';
            receipt_check <= '1';
            wait for 10 ns;
            wait for 10 ns; -- want receipt
            wait for 10 ns; -- dispense
            
            button1 <= '1';
            button2 <= '0';
            button3 <= '0';
            wait for 10 ns; -- valid card input
            valid <= '1';
            wait for 10 ns; -- valid pass input 
            valid_pass <= "100";
            wait for 10 ns;
            button1 <= '0';
            button2 <= '1';
            button3 <= '0';
            wait for 10 ns; -- withdraw
            wait for 10 ns; -- enter money
            with_money <= '1';
            divisble_5 <= '1';
            ava_cash <= '1';
            balance_check <= '1';
            receipt_check <= '0';
            wait for 10 ns;
            wait for 10 ns; 
            wait for 10 ns; -- dispense

            button1 <= '1';
            button2 <= '0';
            button3 <= '0';
            wait for 10 ns; -- valid card input
            valid <= '1';
            wait for 10 ns; -- valid pass input 
            valid_pass <= "000"; --failed password
            wait for 10 ns; -- dispense

            button1 <= '1';
            button2 <= '0';
            button3 <= '0';
            wait for 10 ns; -- valid card input
            valid <= '1';
            wait for 10 ns; -- valid pass input 
            valid_pass <= "100";
            wait for 10 ns;
            button1 <= '0';
            button2 <= '1';
            button3 <= '0';
            wait for 10 ns; -- withdraw
            wait for 10 ns; -- enter money
            with_money <= '1';
            divisble_5 <= '1';
            ava_cash <= '1';
            balance_check <= '1';
            receipt_check <= '0';
            wait for 10 ns;
            wait for 10 ns; 
            wait for 10 ns; -- dispense

            wait;
        end process comb;
end behavoiur;