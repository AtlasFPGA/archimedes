library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture arch of controller_rom2 is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

signal ram : ram_type :=
(

     0 => x"0c040605",
     1 => x"0a830b03",
     2 => x"00070066",
     3 => x"00da005a",
     4 => x"08948000",
     5 => x"00078005",
     6 => x"00018002",
     7 => x"00098003",
     8 => x"00788004",
     9 => x"08918001",
    10 => x"00000026",
    11 => x"0000001d",
    12 => x"0000001c",
    13 => x"00000025",
    14 => x"0000001a",
    15 => x"0000001b",
    16 => x"00000024",
    17 => x"00000112",
    18 => x"0000002e",
    19 => x"0000002d",
    20 => x"00000023",
    21 => x"00000036",
    22 => x"00000021",
    23 => x"0000002b",
    24 => x"0000002c",
    25 => x"00000022",
    26 => x"006c003d",
    27 => x"00000035",
    28 => x"00000034",
    29 => x"0075003e",
    30 => x"00000032",
    31 => x"00000033",
    32 => x"006b003c",
    33 => x"0000002a",
    34 => x"007d0046",
    35 => x"00730043",
    36 => x"0069003b",
    37 => x"00ca0045",
    38 => x"0070003a",
    39 => x"00720042",
    40 => x"00740044",
    41 => x"00000031",
    42 => x"00780055",
    43 => x"007c004d",
    44 => x"007a004b",
    45 => x"007e007b",
    46 => x"00710049",
    47 => x"0084004c",
    48 => x"00770054",
    49 => x"00000041",
    50 => x"00fc0061",
    51 => x"007c005b",
    52 => x"00000052",
    53 => x"007800f1",
    54 => x"00000259",
    55 => x"005d000e",
    56 => x"0000005d",
    57 => x"0079004a",
    58 => x"00000016",
    59 => x"00fc0076",
    60 => x"000d0414",
    61 => x"0000001e",
    62 => x"00000029",
    63 => x"00000011",
    64 => x"00000015",
    65 => x"00004000",
    66 => x"00004110",
    67 => x"000041a5",
    68 => x"3b637241",
    69 => x"3b4d4f52",
    70 => x"2c553053",
    71 => x"2c464441",
    72 => x"706f6c46",
    73 => x"31207970",
    74 => x"31533b3a",
    75 => x"44412c55",
    76 => x"6c462c46",
    77 => x"7970706f",
    78 => x"3b3a3220",
    79 => x"2c553253",
    80 => x"2c464448",
    81 => x"64726148",
    82 => x"73696420",
    83 => x"3a31206b",
    84 => x"5533533b",
    85 => x"4644482c",
    86 => x"7261482c",
    87 => x"69642064",
    88 => x"32206b73",
    89 => x"52533b3a",
    90 => x"41522c55",
    91 => x"6f4c2c4d",
    92 => x"43206461",
    93 => x"20534f4d",
    94 => x"3a4d4152",
    95 => x"5553533b",
    96 => x"4d41522c",
    97 => x"7661532c",
    98 => x"4d432065",
    99 => x"5220534f",
   100 => x"3b3a4d41",
   101 => x"522c3154",
   102 => x"74657365",
   103 => x"762c563b",
   104 => x"2e302e31",
   105 => x"53495200",
   106 => x"20534f43",
   107 => x"4d4f5220",
   108 => x"4d4f5200",
  others => ( x"00000000")
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector((NB_COL * COL_WIDTH)-1 downto 0);

signal wea : std_logic_vector(NB_COL - 1 downto 0);

begin

	output:
	for i in 0 to NB_COL - 1 generate
		q((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= q_local((i+1) * COL_WIDTH - 1 downto i * COL_WIDTH);
	end generate;
    
    -- Generate write enable signals
    -- The Block ram generator doesn't like it when the compare is done in the if statement it self.
    wea <= bytesel when we = '1' else (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            for i in 0 to NB_COL - 1 loop
                if (wea(NB_COL-i-1) = '1') then
                    ram(to_integer(unsigned(addr)))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= d((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                end if;
            end loop;
        end if;
    end process;

end arch;
