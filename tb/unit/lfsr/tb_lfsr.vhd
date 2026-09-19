library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_lfsr is
end entity tb_lfsr;

architecture sim of tb_lfsr is

    constant CLK_PERIOD : time := 20 ns;

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal step        : std_logic := '0';
    signal a_in        : std_logic_vector(3 downto 0) := (others => '0');
    signal en_lfsr_bus : std_logic := '0';

    signal data_bus    : std_logic_vector(3 downto 0) := (others => 'Z');
    signal lfsr_out    : std_logic_vector(3 downto 0);

    signal sim_end     : boolean := false;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: entity work.lfsr
        port map (
            clk         => clk,
            rst         => rst,
            step        => step,
            a_in        => a_in,
            en_lfsr_bus => en_lfsr_bus,
            data_bus    => data_bus,
            lfsr_out    => lfsr_out
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
        report "--- Starting Custom LFSR Unit Test ---";

        -- Test Case 1: Reset Check (Seed = "0001")
        rst <= '1';
        wait for 40 ns;
        assert lfsr_out = "0001"
            report "FAIL: LFSR reset seed expected 0001, got " & to_string(lfsr_out) severity failure;
        rst <= '0';
        wait for 20 ns;
        report "SUCCESS: Reset initialized seed to '0001'.";

        -- Test Case 2: Hold State when step = '0'
        report "--- Case 2: Hold state when step = 0 ---";
        step <= '0';
        a_in <= "0101";
        wait for 3 * CLK_PERIOD;
        assert lfsr_out = "0001"
            report "FAIL: LFSR state changed while step = 0" severity failure;
        report "SUCCESS: LFSR held state when step = 0.";

        -- Test Case 3: Pure Shift Step (a_in = "0000")
        -- Seed "0001" -> c_bit = 1 xor 0 = 1 -> shift = "0011" + 0 = "0011"
        report "--- Case 3: Step 1 (a_in = 0000) ---";
        wait until falling_edge(clk);
        a_in <= "0000";
        step <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;
        assert lfsr_out = "0011"
            report "FAIL: Step 1 expected 0011, got " & to_string(lfsr_out) severity failure;
        report "SUCCESS: Step 1 produced '0011'.";

        -- Test Case 4: Step with Reg A Addition (a_in = "0010")
        -- State "0011" -> c_bit = 1 xor 1 = 0 -> shift = "0110" + "0010" = "1000"
        report "--- Case 4: Step 2 with Reg A Addition (a_in = 0010) ---";
        wait until falling_edge(clk);
        a_in <= "0010";

        wait until rising_edge(clk);
        wait for 1 ns;
        assert lfsr_out = "1000"
            report "FAIL: Step 2 expected 1000, got " & to_string(lfsr_out) severity failure;
        report "SUCCESS: Step 2 with Reg A addition produced '1000'.";

        step <= '0';

        -- Test Case 5: Bus Driver Output
        report "--- Case 5: Drive Data Bus ---";
        en_lfsr_bus <= '0';
        wait for 10 ns;
        assert data_bus = "ZZZZ" report "FAIL: Data bus should be high-Z" severity failure;

        en_lfsr_bus <= '1';
        wait for 10 ns;
        assert data_bus = "1000" report "FAIL: Data bus expected 1000 from LFSR" severity failure;
        report "SUCCESS: LFSR drove '1000' onto Data Bus.";

        en_lfsr_bus <= '0';
        wait for 10 ns;
        assert data_bus = "ZZZZ" report "FAIL: Data bus did not release to high-Z" severity failure;

        sim_end <= true;
        report "=== LFSR MODULE TEST PASSED ===";
        wait;
    end process;

end architecture sim;