library ieee;
use ieee.std_logic_1164.all;

entity tb_clock is
end entity tb_clock;

architecture sim of tb_clock is

    constant CLK_PERIOD : time := 20 ns;
    
    signal clk_in  : std_logic := '0';
    signal rst     : std_logic := '0';
    signal hlt     : std_logic := '0';
    signal clk_out : std_logic;
    
    signal sim_end : boolean := false;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: entity work.clock
        port map (
            clk_in  => clk_in,
            rst     => rst,
            hlt     => hlt,
            clk_out => clk_out
        );

    -- Master Clock Oscillator Process
    clk_gen: process
    begin
        while not sim_end loop
            clk_in <= '0';
            wait for CLK_PERIOD / 2;
            clk_in <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Test Stimulus Process
    stim_proc: process
    begin
        report "--- Starting Clock Unit Test ---";
        
        -- Test Case 1: Initial Reset
        rst <= '1';
        wait for 40 ns;
        assert clk_out = '0' 
            report "FAIL: clk_out should be suppressed during reset" severity failure;
        
        -- Release Reset -> Clock should start toggling
        rst <= '0';
        wait for 100 ns;
        assert clk_out'event or clk_out = clk_in 
            report "FAIL: clk_out should toggle after reset release" severity failure;
        
        -- Test Case 2: Trigger Halt
        report "--- Triggering Halt Signal ---";
        wait until falling_edge(clk_in);
        hlt <= '1';
        wait for 40 ns;
        hlt <= '0';
        
        -- Verify output clock freezes
        wait for 60 ns;
        assert clk_out = '0' 
            report "FAIL: clk_out did not freeze after HLT signal assertion" severity failure;
        report "SUCCESS: Clock halted as expected.";

        -- Test Case 3: Re-reset System
        report "--- Resetting Halted System ---";
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 60 ns;
        
        assert clk_out'event or clk_out = clk_in 
            report "FAIL: clk_out did not resume after reset" severity failure;
        report "SUCCESS: Clock resumed after reset.";

        sim_end <= true;
        report "=== CLOCK MODULE TEST PASSED ===";
        wait;
    end process;

end architecture sim;