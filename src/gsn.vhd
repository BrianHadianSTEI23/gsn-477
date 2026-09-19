library ieee;
use ieee.std_logic_1164.all;

entity gsn is
    port (
        clk_in        : in  std_logic;                    -- Master oscillator clock
        rst           : in  std_logic;                    -- Global system reset
        
        -- Diagnostic & Framebuffer Outputs
        pc_out        : out std_logic_vector(3 downto 0); -- Current Program Counter
        op_out        : out std_logic_vector(3 downto 0); -- Currently loaded Opcode
        a_out         : out std_logic_vector(3 downto 0); -- Accumulator value
        b_out         : out std_logic_vector(3 downto 0); -- Register B value
        fb_out        : out std_logic_vector(3 downto 0); -- Framebuffer 4-bit state
        ansi_char_out : out std_logic_vector(7 downto 0); -- Decoded ANSI ASCII output
        halted_out    : out std_logic                     -- System halted flag
    );
end entity gsn;

architecture structural of gsn is

    -- System Clock & Timers
    signal clk_sys    : std_logic;
    signal hlt        : std_logic;
    signal t_state    : std_logic_vector(6 downto 0);

    -- Shared Tri-State Data Bus
    signal data_bus   : std_logic_vector(3 downto 0);

    -- Control Signals from Opcode Decoder
    signal inc_pc      : std_logic;
    signal en_mem_bus  : std_logic;
    signal load_a      : std_logic;
    signal en_a_bus    : std_logic;
    signal load_b      : std_logic;
    signal en_sub      : std_logic;
    signal en_alu_bus  : std_logic;
    signal step_lfsr   : std_logic;
    signal en_lfsr_bus : std_logic;

    -- Internal Module Interconnects
    signal pc_val      : std_logic_vector(3 downto 0);
    signal mem_val     : std_logic_vector(3 downto 0);
    signal reg_a_val   : std_logic_vector(3 downto 0);
    signal reg_b_val   : std_logic_vector(3 downto 0);
    signal lfsr_val    : std_logic_vector(3 downto 0);
    signal op_val      : std_logic_vector(3 downto 0);

begin

    -- 1. Clock Module
    clock_inst: entity work.clock
        port map (
            clk_in  => clk_in,
            rst     => rst,
            hlt     => hlt,
            clk_out => clk_sys
        );

    -- 2. Program Counter
    pc_inst: entity work.program_counter
        port map (
            clk    => clk_sys,
            rst    => rst,
            inc    => inc_pc,
            pc_out => pc_val
        );

    -- 3. Ring Counter (Micro-step Generator)
    ring_inst: entity work.ring_counter
        port map (
            clk   => clk_sys,
            rst   => rst,
            t_out => t_state
        );

    -- 4. Memory (RAM / Program Storage)
    mem_inst: entity work.memory
        port map (
            clk        => clk_sys,
            rst        => rst,
            addr       => pc_val,
            write_en   => '0',
            en_mem_bus => en_mem_bus,
            data_bus   => data_bus,
            mem_out    => mem_val
        );

    -- 5. Opcode Decoder & Control Matrix
    opcode_inst: entity work.opcode_decoder
        port map (
            clk         => clk_sys,
            rst         => rst,
            data_bus    => data_bus,
            t_in        => t_state,
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
            op_out      => op_val
        );

    -- 6. Accumulator Register A
    reg_a_inst: entity work.a_register
        port map (
            clk      => clk_sys,
            rst      => rst,
            load_a   => load_a,
            en_a_bus => en_a_bus,
            data_bus => data_bus,
            a_out    => reg_a_val
        );

    -- 7. Register B
    reg_b_inst: entity work.b_register
        port map (
            clk     => clk_sys,
            rst     => rst,
            load_b  => load_b,
            data_in => data_bus,
            b_out   => reg_b_val
        );

    -- 8. Arithmetic Logic Unit (ALU)
    alu_inst: entity work.alu
        port map (
            a_in       => reg_a_val,
            b_in       => reg_b_val,
            en_sub     => en_sub,
            en_alu_bus => en_alu_bus,
            data_bus   => data_bus,
            alu_out    => open,
            carry_out  => open
        );

    -- 9. Custom LFSR Module
    lfsr_inst: entity work.lfsr
        port map (
            clk         => clk_sys,
            rst         => rst,
            step        => step_lfsr,
            a_in        => reg_a_val,
            en_lfsr_bus => en_lfsr_bus,
            data_bus    => data_bus,
            lfsr_out    => lfsr_val
        );

    -- 10. Framebuffer Decoder (Mirrors Accumulator updates)
    fb_inst: entity work.framebuffer_decoder
        port map (
            clk       => clk_sys,
            rst       => rst,
            load_fb   => load_a,
            data_in   => reg_a_val,
            fb_out    => fb_out,
            ansi_char => ansi_char_out
        );

    -- External Output Assignments
    pc_out     <= pc_val;
    op_out     <= op_val;
    a_out      <= reg_a_val;
    b_out      <= reg_b_val;
    halted_out <= hlt;

end architecture structural;