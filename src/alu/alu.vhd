library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a_in       : in    std_logic_vector(3 downto 0); -- Input from Accumulator (Reg A)
        b_in       : in    std_logic_vector(3 downto 0); -- Input from Register B
        en_sub     : in    std_logic;                    -- Operation select: '0' = ADD, '1' = SUB
        en_alu_bus : in    std_logic;                    -- Tri-state enable to Data Bus
        data_bus   : inout std_logic_vector(3 downto 0); -- Tri-state shared Data Bus
        alu_out    : out   std_logic_vector(3 downto 0); -- Direct output to internal registers
        carry_out  : out   std_logic                     -- Overflow / Carry bit
    );
end entity alu;

architecture behavioral of alu is
    signal res_ext : unsigned(4 downto 0) := (others => '0');
    signal result  : std_logic_vector(3 downto 0);
begin

    process(a_in, b_in, en_sub)
        variable v_a : unsigned(4 downto 0);
        variable v_b : unsigned(4 downto 0);
    begin
        v_a := unsigned('0' & a_in);

        if en_sub = '1' then
            -- Subtraction via 2's Complement: A + (~B) + 1
            v_b := unsigned('0' & (not b_in));
            res_ext <= v_a + v_b + 1;
        else
            -- Standard Addition: A + B
            v_b := unsigned('0' & b_in);
            res_ext <= v_a + v_b;
        end if;
    end process;

    result    <= std_logic_vector(res_ext(3 downto 0));
    carry_out <= res_ext(4);
    alu_out   <= result;

    -- Tri-State Buffer to Data Bus
    data_bus <= result when en_alu_bus = '1' else (others => 'Z');

end architecture behavioral;