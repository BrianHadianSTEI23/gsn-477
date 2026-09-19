library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_program_counter is
end entity tb_program_counter;

architecture sim of tb_program_counter is

    constant CLK_PERIOD : time := 20 ns;

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal inc    : std_logic := '0';
    signal pc_out : std_logic_vector(3 downto 0);

    signal sim_end : boolean := false;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: entity work.program_counter
        port map (
            clk    => clk,
            rst    => rst,
            inc    => inc,
            pc_out => pc_out
        );

    -- Clock Generation
    clk_gen: process
    begin
        while not sim_end loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        report "--- Starting Program Counter Unit Test ---";

        -- Test Case 1: Reset Behavior
        rst <= '1';
        inc <= '0';
        wait for 40 ns;
        assert pc_out = "0000" 
            report "FAIL: PC should be 0000 on reset" severity failure;
        
        rst <= '0';
        wait for 20 ns;

        -- Test Case 2: Hold State when inc = '0'
        wait until falling_edge(clk);
        inc <= '0';
        wait for 3 * CLK_PERIOD;
        assert pc_out = "0000" 
            report "FAIL: PC changed value while inc = '0'" severity failure;
        report "SUCCESS: PC held value when disabled.";

        -- Test Case 3: Incrementing Counter
        report "--- Incrementing PC across cycles ---";
        wait until falling_edge(clk);
        inc <= '1';
        
        -- Step through 5 increments
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        
        wait for 1 ns; -- Small delay for propagation
        assert pc_out = "0101" 
            report "FAIL: Expected PC = 0101 (5), got " & to_hstring(pc_out) severity failure;
        report "SUCCESS: PC incremented to 0101.";

        -- Test Case 4: Overflow / Wrap-Around Test (15 -> 0)
        report "--- Testing Counter Wrap-Around ---";
        -- Advance 10 more times (5 + 10 = 15 = "1111")
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        
        wait for 1 ns;
        assert pc_out = "1111" 
            report "FAIL: Expected PC = 1111 (15), got " & to_hstring(pc_out) severity failure;

        -- One more increment should wrap around to 0
        wait until rising_edge(clk);
        wait for 1 ns;
        assert pc_out = "0000" 
            report "FAIL: PC did not wrap around to 0000" severity failure;
        report "SUCCESS: PC correctly wrapped around to 0000.";

        -- Disable incrementing
        inc <= '0';
        wait for 20 ns;

        sim_end <= true;
        report "=== PROGRAM COUNTER MODULE TEST PASSED ===";
        wait;
    end process;

end architecture sim;