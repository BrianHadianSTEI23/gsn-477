library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is
    port (
        clk         : in    std_logic;                    -- System clock
        rst         : in    std_logic;                    -- Global reset (resets seed to "0001")
        step        : in    std_logic;                    -- LFSR step trigger signal
        a_in        : in    std_logic_vector(3 downto 0); -- Operand input from Accumulator (Reg A)
        en_lfsr_bus : in    std_logic;                    -- Tri-state enable to Data Bus
        data_bus    : inout std_logic_vector(3 downto 0); -- Shared 4-bit Data Bus
        lfsr_out    : out   std_logic_vector(3 downto 0)  -- Direct output port
    );
end entity lfsr;

architecture behavioral of lfsr is
    signal r_reg : std_logic_vector(3 downto 0) := "0001";
begin

    process(clk, rst)
        variable c_bit      : std_logic;
        variable shifted    : std_logic_vector(3 downto 0);
        variable sum_result : unsigned(3 downto 0);
    begin
        if rst = '1' then
            r_reg <= "0001"; -- Default non-zero seed
        elsif rising_edge(clk) then
            if step = '1' then
                -- Calculate feedback bit via XOR of bit 0 and bit 1
                c_bit := r_reg(0) xor r_reg(1);
                
                -- Shift left and insert feedback bit at LSB
                shifted := r_reg(2 downto 0) & c_bit;
                
                -- Add value from Register A
                sum_result := unsigned(shifted) + unsigned(a_in);
                
                -- Update register
                r_reg <= std_logic_vector(sum_result);
            end if;
        end if;
    end process;

    lfsr_out <= r_reg;

    -- Tri-State Buffer to Data Bus
    data_bus <= r_reg when en_lfsr_bus = '1' else (others => 'Z');

end architecture behavioral;