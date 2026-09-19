library ieee;
use ieee.std_logic_1164.all;

entity opcode_decoder is
    port (
        clk         : in  std_logic;                     -- System clock
        rst         : in  std_logic;                     -- Global reset
        data_bus    : in  std_logic_vector(3 downto 0);  -- Shared 4-bit Data Bus
        t_in        : in  std_logic_vector(6 downto 0);  -- 7-bit T-state vector from Ring Counter
        
        -- Control Signal Outputs
        inc_pc      : out std_logic;                     -- Increment Program Counter
        en_mem_bus  : out std_logic;                     -- Enable Memory output to Data Bus
        load_a      : out std_logic;                     -- Load Register A
        en_a_bus    : out std_logic;                     -- Enable Register A output to Data Bus
        load_b      : out std_logic;                     -- Load Register B
        en_sub      : out std_logic;                     -- ALU Subtract control
        en_alu_bus  : out std_logic;                     -- Enable ALU output to Data Bus
        step_lfsr   : out std_logic;                     -- Trigger LFSR state update
        en_lfsr_bus : out std_logic;                     -- Enable LFSR output to Data Bus
        hlt         : out std_logic;                     -- System Halt signal
        op_out      : out std_logic_vector(3 downto 0)   -- Latched opcode output
    );
end entity opcode_decoder;

architecture behavioral of opcode_decoder is
    signal ir_reg : std_logic_vector(3 downto 0) := (others => '0');
begin

    -- Instruction Register Latch Process (Latches on T1 timing state)
    process(clk, rst)
    begin
        if rst = '1' then
            ir_reg <= "0000";
        elsif rising_edge(clk) then
            if t_in(0) = '1' then -- T1 state: Latch instruction from memory bus
                ir_reg <= data_bus;
            end if;
        end if;
    end process;

    op_out <= ir_reg;

    -- Combinational Control Matrix Decoder
    process(ir_reg, t_in)
    begin
        -- Default control signal states (Inactive)
        inc_pc      <= '0';
        en_mem_bus  <= '0';
        load_a      <= '0';
        en_a_bus    <= '0';
        load_b      <= '0';
        en_sub      <= '0';
        en_alu_bus  <= '0';
        step_lfsr   <= '0';
        en_lfsr_bus <= '0';
        hlt         <= '0';

        -- Common Fetch Micro-operations:
        -- T1: Memory drives Data Bus (Opcode latch handled in process above)
        if t_in(0) = '1' then
            en_mem_bus <= '1';
        -- T2: Increment PC to point to next instruction / operand
        elsif t_in(1) = '1' then
            inc_pc <= '1';
        
        -- Instruction Execution Micro-operations (T3 - T7)
        else
            case ir_reg is
                when "0001" => -- LDA: Load Memory to Register A
                    if t_in(2) = '1' then -- T3
                        en_mem_bus <= '1';
                        load_a     <= '1';
                    end if;

                when "0010" => -- ADD: Reg A = Reg A + Reg B
                    if t_in(2) = '1' then -- T3
                        en_alu_bus <= '1';
                        en_sub     <= '0';
                        load_a     <= '1';
                    end if;

                when "0011" => -- SUB: Reg A = Reg A - Reg B
                    if t_in(2) = '1' then -- T3
                        en_alu_bus <= '1';
                        en_sub     <= '1';
                        load_a     <= '1';
                    end if;

                when "0100" => -- LDB: Load Memory to Register B
                    if t_in(2) = '1' then -- T3
                        en_mem_bus <= '1';
                        load_b     <= '1';
                    end if;

                when "0101" => -- RND: Step LFSR and store in Reg A
                    if t_in(2) = '1' then -- T3: Step LFSR logic
                        step_lfsr <= '1';
                    elsif t_in(3) = '1' then -- T4: Put LFSR result into Reg A
                        en_lfsr_bus <= '1';
                        load_a      <= '1';
                    end if;

                when "1111" => -- HLT: Assert System Halt
                    if t_in(2) = '1' then -- T3
                        hlt <= '1';
                    end if;

                when others =>
                    null; -- NOP or unmapped opcodes
            end case;
        end if;
    end process;

end architecture behavioral;