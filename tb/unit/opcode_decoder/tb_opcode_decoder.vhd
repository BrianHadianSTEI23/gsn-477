library ieee;
use ieee.std_logic_1164.all;

entity tb_opcode_decoder is
end entity tb_opcode_decoder;

architecture sim of tb_opcode_decoder is

    constant CLK_PERIOD : time := 20 ns;

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal data_bus    : std_logic_vector(3 downto 0) := (others => '0');
    signal t_in        : std_logic_vector(6 downto 0) := "0000001"; -- Start at T1

    -- Control Signals
    signal inc_pc      : std_logic;
    signal en_mem_bus  : std_logic;
    signal load_a      : std_logic;
    signal en_a_bus    : std_logic;
    signal load_b      : std_logic;
    signal en_sub      : std_logic;
    signal en_alu_bus  : std_logic;
    signal step_lfsr   : std_logic;
    signal en_lfsr_bus : std_logic;
    signal hlt         : std_logic;
    signal op_out      : std_logic_vector(3 downto 0);

    signal sim_end     : boolean := false;

begin

    uut: entity work.opcode_decoder
        port map (
            clk         => clk,
            rst         => rst,
            data_bus    => data_bus,
            t_in        => t_in,
            inc_pc      => inc_pc,
            en_mem_bus  => en_mem_bus,
            load_a      => load_a,
            en_a_bus    => en_a_bus,
            load_b      => load_b,
            en_sub      => en_sub,
            en_alu_bus  => en_alu_bus,
            step_lfsr   => step_lfsr,
            en_lfsr_bus => en_lfsr_bus,
            hlt         => hlt,
            op_out      => op_out
        );

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

    stim_proc: process
    begin
        report "--- Starting Opcode Decoder Unit Test ---";

        -- Reset Check
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        ------------------------------------------------------------------
        -- Test Case 1: Fetch Cycle & ADD Instruction Decode ("0010")
        ------------------------------------------------------------------
        report "--- Case 1: Fetch and Decode ADD Instruction ('0010') ---";
        data_bus <= "0010"; -- ADD opcode on bus
        t_in     <= "0000001"; -- T1
        wait for 5 ns;
        assert en_mem_bus = '1' report "FAIL: T1 should assert en_mem_bus" severity failure;

        wait until rising_edge(clk); -- Clock latches Opcode in T1
        wait for 1 ns;
        assert op_out = "0010" report "FAIL: Opcode 0010 not latched" severity failure;

        -- Move to T2
        t_in <= "0000010"; -- T2
        wait for 5 ns;
        assert inc_pc = '1' report "FAIL: T2 should assert inc_pc" severity failure;

        -- Move to T3 (Execution Phase of ADD)
        t_in <= "0000100"; -- T3
        wait for 5 ns;
        assert en_alu_bus = '1' and load_a = '1' and en_sub = '0'
            report "FAIL: ADD execution control signals incorrect" severity failure;
        report "SUCCESS: ADD instruction decoded properly.";

        ------------------------------------------------------------------
        -- Test Case 2: SUB Instruction Decode ("0011")
        ------------------------------------------------------------------
        report "--- Case 2: Decode SUB Instruction ('0011') ---";
        data_bus <= "0011";
        t_in     <= "0000001"; -- T1
        wait until rising_edge(clk);
        
        t_in <= "0000100"; -- Jump to T3
        wait for 5 ns;
        assert en_alu_bus = '1' and load_a = '1' and en_sub = '1'
            report "FAIL: SUB execution control signals incorrect" severity failure;
        report "SUCCESS: SUB instruction decoded properly.";

        ------------------------------------------------------------------
        -- Test Case 3: HLT Instruction Decode ("1111")
        ------------------------------------------------------------------
        report "--- Case 3: Decode HLT Instruction ('1111') ---";
        data_bus <= "1111";
        t_in     <= "0000001"; -- T1
        wait until rising_edge(clk);
        
        t_in <= "0000100"; -- T3
        wait for 5 ns;
        assert hlt = '1' report "FAIL: HLT signal not asserted" severity failure;
        report "SUCCESS: HLT instruction decoded properly.";

        sim_end <= true;
        report "=== OPCODE DECODER TEST PASSED ===";
        wait;
    end process;

end architecture sim;