library ieee;
use ieee.std_logic_1164.all;

entity tb_ring_counter is
end entity tb_ring_counter;

architecture sim of tb_ring_counter is

    constant CLK_PERIOD : time := 20 ns;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal t_out : std_logic_vector(6 downto 0);

    signal sim_end : boolean := false;

    -- Expected T-states in sequence
    type t_state_array is array (0 to 6) of std_logic_vector(6 downto 0);
    constant EXPECTED_STATES : t_state_array := (
        "0000001", -- T1
        "0000010", -- T2
        "0000100", -- T3
        "0001000", -- (Wait - strictly 7-bit one-hot)
        "0010000", -- T4
        "0100000", -- T5
        "1000000"  -- T6 (Note: T1..T7 index mapped below)
    );

begin

    -- Instantiate Unit Under Test (UUT)
    uut: entity work.ring_counter
        port map (
            clk   => clk,
            rst   => rst,
            t_out => t_out
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
        -- Expected sequence for T1 through T7
        type seq_array is array (1 to 7) of std_logic_vector(6 downto 0);
        constant SEQ : seq_array := (
            1 => "0000001", -- T1
            2 => "0000010", -- T2
            3 => "0000100", -- T3
            4 => "0001000", -- T4
            5 => "0010000", -- T5
            6 => "0100000", -- T6
            7 => "1000000"  -- T7
        );
    begin
        report "--- Starting Ring Counter Unit Test ---";

        -- Test Case 1: Initial Reset Behavior
        rst <= '1';
        wait for 40 ns;
        assert t_out = "0000001"
            report "FAIL: Ring counter should be T1 (0000001) on reset" severity failure;
        
        rst <= '0';
        wait for 10 ns;

        -- Test Case 2: Verify Full T1 -> T7 Sequence
        report "--- Testing T1 to T7 Rotation Sequence ---";
        for step in 1 to 7 loop
            assert t_out = SEQ(step)
                report "FAIL: Step " & integer'image(step) & 
                       " expected " & to_string(SEQ(step)) & 
                       ", got " & to_string(t_out) severity failure;
            report "State T" & integer'image(step) & ": " & to_string(t_out);
            wait until rising_edge(clk);
            wait for 1 ns; -- Propagation settling time
        end loop;

        -- Test Case 3: Verify Wrap-Around Back to T1
        report "--- Testing Wrap-Around to T1 ---";
        assert t_out = "0000001"
            report "FAIL: Ring counter failed to wrap around to T1 (0000001)" severity failure;
        report "SUCCESS: Wrapped back to T1 correctly.";

        -- Test Case 4: Asynchronous / Synchronous Mid-Cycle Reset
        report "--- Testing Mid-Cycle Reset ---";
        -- Advance to T3
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ns;
        assert t_out = "0000100" report "FAIL: Should be at T3" severity failure;

        -- Apply reset
        rst <= '1';
        wait for 20 ns;
        assert t_out = "0000001" report "FAIL: Reset failed to restore T1" severity failure;
        
        rst <= '0';
        wait for 20 ns;

        sim_end <= true;
        report "=== RING COUNTER MODULE TEST PASSED ===";
        wait;
    end process;

end architecture sim;