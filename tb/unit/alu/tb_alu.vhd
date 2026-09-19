library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is
end entity tb_alu;

architecture sim of tb_alu is

    signal a_in       : std_logic_vector(3 downto 0) := (others => '0');
    signal b_in       : std_logic_vector(3 downto 0) := (others => '0');
    signal en_sub     : std_logic := '0';
    signal en_alu_bus : std_logic := '0';
    
    signal data_bus   : std_logic_vector(3 downto 0) := (others => 'Z');
    signal alu_out    : std_logic_vector(3 downto 0);
    signal carry_out  : std_logic;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: entity work.alu
        port map (
            a_in       => a_in,
            b_in       => b_in,
            en_sub     => en_sub,
            en_alu_bus => en_alu_bus,
            data_bus   => data_bus,
            alu_out    => alu_out,
            carry_out  => carry_out
        );

    -- Combinational Stimulus Process
    stim_proc: process
    begin
        report "--- Starting ALU Unit Test ---";

        ------------------------------------------------------------------
        -- Test Case 1: Simple Addition (3 + 4 = 7, Carry = 0)
        ------------------------------------------------------------------
        report "--- Case 1: ADD 3 + 4 ---";
        a_in       <= "0011"; -- 3
        b_in       <= "0100"; -- 4
        en_sub     <= '0';
        en_alu_bus <= '0';
        wait for 10 ns;

        assert alu_out = "0111" 
            report "FAIL: 3 + 4 expected 0111, got " & to_string(alu_out) severity failure;
        assert carry_out = '0' 
            report "FAIL: Carry bit should be 0" severity failure;
        assert data_bus = "ZZZZ" 
            report "FAIL: Data bus should be high-Z" severity failure;
        report "SUCCESS: 3 + 4 = 7 (Carry 0).";

        ------------------------------------------------------------------
        -- Test Case 2: Addition with Carry Overflow (9 + 8 = 17 -> 1, Carry = 1)
        ------------------------------------------------------------------
        report "--- Case 2: ADD 9 + 8 (Overflow) ---";
        a_in   <= "1001"; -- 9
        b_in   <= "1000"; -- 8
        en_sub <= '0';
        wait for 10 ns;

        assert alu_out = "0001" 
            report "FAIL: 9 + 8 lower bits expected 0001, got " & to_string(alu_out) severity failure;
        assert carry_out = '1' 
            report "FAIL: Carry bit expected 1" severity failure;
        report "SUCCESS: 9 + 8 = 1 with Carry Out = 1.";

        ------------------------------------------------------------------
        -- Test Case 3: Subtraction (9 - 4 = 5)
        ------------------------------------------------------------------
        report "--- Case 3: SUB 9 - 4 ---";
        a_in   <= "1001"; -- 9
        b_in   <= "0100"; -- 4
        en_sub <= '1';
        wait for 10 ns;

        assert alu_out = "0101" 
            report "FAIL: 9 - 4 expected 0101, got " & to_string(alu_out) severity failure;
        report "SUCCESS: 9 - 4 = 5.";

        ------------------------------------------------------------------
        -- Test Case 4: Subtraction with Negative Result (3 - 5 = -2 -> 14 in 2's complement)
        ------------------------------------------------------------------
        report "--- Case 4: SUB 3 - 5 (Negative Result) ---";
        a_in   <= "0011"; -- 3
        b_in   <= "0101"; -- 5
        en_sub <= '1';
        wait for 10 ns;

        assert alu_out = "1110" 
            report "FAIL: 3 - 5 expected 1110 (-2), got " & to_string(alu_out) severity failure;
        report "SUCCESS: 3 - 5 = 1110 (-2).";

        ------------------------------------------------------------------
        -- Test Case 5: Bus Driver Enable (en_alu_bus)
        ------------------------------------------------------------------
        report "--- Case 5: Drive Data Bus ---";
        a_in       <= "0010"; -- 2
        b_in       <= "0011"; -- 3
        en_sub     <= '0';    -- 2 + 3 = 5 ("0101")
        en_alu_bus <= '1';
        wait for 10 ns;

        assert data_bus = "0101" 
            report "FAIL: Data bus did not drive 0101" severity failure;
        report "SUCCESS: ALU drove 0101 onto Data Bus.";

        en_alu_bus <= '0';
        wait for 10 ns;
        assert data_bus = "ZZZZ" 
            report "FAIL: Data bus failed to release to high-Z" severity failure;

        report "=== ALU MODULE TEST PASSED ===";
        wait;
    end process;

end architecture sim;