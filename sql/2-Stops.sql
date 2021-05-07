/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `plumeesx`
--

-- --------------------------------------------------------

--
-- Table structure for table `lachee_bus_routes`
--

CREATE TABLE `lachee_bus_routes` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL COMMENT 'Name of the route',
  `multiplier` float NOT NULL DEFAULT 1 COMMENT 'How much more or less this route gives from the standard rate.',
  `minimum_grade` int(11) NOT NULL DEFAULT 0 COMMENT 'Minimum grade needed to do this route',
  `type` varchar(16) NOT NULL DEFAULT 'metro' COMMENT 'type of route (rural, metro, airport)',
  `route` text NOT NULL DEFAULT '[]' COMMENT 'JSON Encoded array of stop ids.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `lachee_bus_routes`
--

INSERT INTO `lachee_bus_routes` (`id`, `name`, `multiplier`, `minimum_grade`, `type`, `route`) VALUES
(1, 'Sandy Shores X-Press', 1.25, 0, 'rural', '[ 38, 40, 38 ]'),
(2, 'Small Metro Route', 0.8, 0, 'metro', '[ 3, 5, 6, 8, 38 ]'),
(3, 'Long Beach Route', 1, 0, 'metro', '[ 27, 28, 29, 30, 36, 37, 49, 14, 8, 38 ]'),
(4, 'Long Rural Route', 1.5, 0, 'rural', '[ 38, 40, 41, 46, 45, 38 ]'),
(5, 'Industry', 1, 0, 'metro', '[ 50, 25, 24, 22, 18, 16, 38 ]'),
(6, 'Medium Metro Route', 1, 0, 'metro', '[ 5, 31, 32, 36, 12, 13, 11, 10, 38 ]');

-- --------------------------------------------------------

--
-- Table structure for table `lachee_bus_stops`
--

CREATE TABLE `lachee_bus_stops` (
  `id` int(11) NOT NULL,
  `hash` varchar(64) NOT NULL COMMENT 'sha1 of model coords',
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `heading` float NOT NULL,
  `qx` float NOT NULL,
  `qy` float NOT NULL,
  `qz` float NOT NULL,
  `name` text NOT NULL,
  `type` varchar(16) NOT NULL DEFAULT 'metro',
  `clear` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `lachee_bus_stops`
--

INSERT INTO `lachee_bus_stops` (`id`, `hash`, `x`, `y`, `z`, `heading`, `qx`, `qy`, `qz`, `name`, `type`, `clear`) VALUES
(1, '606dbac7bf2b741aabd73fcd6896b47dc295623f', 355.253, -1063.94, 29.3906, 268.697, 357.955, -1068.46, 29.553, 'Vespucci Blvd  E', 'metro', 0),
(2, 'd9a9f2adb978665aaaefb181db80833bcd940590', 264.899, -1124.19, 29.2119, 88.6775, 256.332, -1119.61, 29.3561, 'Adam\'s Apple Blvd  W', 'metro', 0),
(3, '84e7d3e499860ecf52b39a60a01af0394c08ea35', 308.745, -761.421, 29.2311, 163.148, 0, 0, 0, 'Strawberry Ave  S', 'metro', 0),
(5, '2541990e50d608b1ac0f692a0ee86495fa5d6e59', 118.576, -786.144, 31.419, 70, 0, 0, 0, 'San Andreas Ave  W', 'metro', 0),
(6, '1bb56cfec0f561fd5f4948c0a371d61de419fa56', -171.367, -816.12, 31.166, 159.84, 0, 0, 0, 'Alta St  S', 'metro', 0),
(7, '3032b0b3b26657ae228eeaa9f95e2acc7adc1907', -252.653, -881.766, 30.6868, 249.904, 0, 0, 0, 'Vespucci Blvd  E', 'metro', 0),
(8, '22be07930b5af4b765c8cf5c69d6eeb21ea5336c', -273.329, -827.684, 31.7272, 341.344, 0, 0, 0, 'Peaceful St Vespucci Blvd N', 'metro', 0),
(9, 'f6fab66d76ae2bcca2387bbd72aaf1ca46d8a896', -244.371, -711.837, 33.4295, 160.115, 0, 0, 0, 'Peaceful St San Andreas Ave S', 'metro', 0),
(10, '0ea7892fa2af6d3243442c1f5aa0c4241f178401', -511.119, -667.722, 33.0639, 270.944, 0, 0, 0, 'San Andreas Ave  E', 'metro', 0),
(11, 'f12ec93186728c81e7f69ec6ba3df391344aab6f', -696.408, -668.147, 30.8236, 270, 0, 0, 0, 'San Andreas Ave  E', 'metro', 0),
(12, '19db9f25643eb21c8b7d810a08e741da6daec22b', -707.914, -827.722, 23.4815, 90, 0, 0, 0, 'Vespucci Blvd Ginger St W', 'metro', 0),
(13, 'c1ecfb70c7e8d7f79dba850279e07ecc43ba6c94', -740.696, -755.317, 26.4751, 0.307413, 0, 0, 0, 'Ginger St  N', 'metro', 0),
(14, '0d078595247af6c0fada6343623d65d10e250167', -563.812, -846.385, 27.0341, 270.158, 0, 0, 0, 'Vespucci Blvd  E', 'metro', 0),
(15, '3b5cfda1805900881b3ee7fdc8e61a62ae1cf523', -104.86, -1684.46, 29.2273, 139.742, 0, 0, 0, 'Strawberry Ave Davis Ave SW', 'metro', 0),
(16, '1ab21a0978ae0f5ec7a47f88989cc7243117ce61', 47.9691, -1538.26, 29.3447, 320, 57.2285, -1539.15, 29.2939, 'Strawberry Ave Macdonald St NE', 'metro', 0),
(17, '4ac5fed851cc26272f7b979af5d9900b2f24dee5', 359.368, -1784.53, 28.9633, 320.652, 0, 0, 0, 'Roy Lowenstein Blvd Macdonald St NE', 'metro', 0),
(18, '07280a53c7fd80f35a4e7cc2647b717b1fcaebea', 437.213, -2026.75, 23.3423, 223.246, 0, 0, 0, 'Carson Ave  SE', 'metro', 0),
(19, '897b96365f354c9af0deb80801c5b83a408e9d2f', 770.514, -1750.66, 29.423, 262.533, 0, 0, 0, 'Innocence Blvd  E', 'metro', 0),
(20, '2198b8ed71d670e7adee95daca9e21ad94254a7d', 873.845, -1765.82, 29.7763, 262.765, 0, 0, 0, 'Innocence Blvd Popular St E', 'metro', 0),
(21, 'e2178abe6a79522cc3b22f5ce657e7b84192eebb', 936.563, -1752.85, 31.0723, 87.0086, 0, 0, 0, 'Innocence Blvd Orchardville Ave W', 'metro', 0),
(22, 'aab47fb196ce9e93a45eccb6a30f5f1b8deae7bb', 826.433, -1634.42, 30.5628, 174.695, 0, 0, 0, 'Popular St  S', 'metro', 0),
(23, 'f4db354681f60617f30bd165c4b5e750ec39896c', 807.145, -1356.94, 26.2625, 0.0000915527, 0, 0, 0, 'Popular St Olympic Fwy N', 'metro', 0),
(24, '193f7d50e5915ffac20fbbf6d05a921a60e67e9f', 788.697, -1364.43, 26.451, 178.864, 0, 0, 0, 'Popular St Olympic Fwy S', 'metro', 0),
(25, 'a603e28e691124dca4c71a649416c44751f96cdb', 771.68, -938.991, 25.6343, 185.068, 0, 0, 0, 'Popular St  S', 'metro', 0),
(26, 'f48585aa57199f2b5f547e0f63156c9812330707', 785.05, -780.887, 26.3451, 0.0015564, 0, 0, 0, 'Popular St  N', 'metro', 0),
(27, '93b89d32e11dccad684fca3caec9e4a422d5ac2c', -496.892, 20.1225, 44.8445, 89.5643, 0, 0, 0, 'Hawick Ave Boulevard Del Perro W', 'metro', 0),
(28, '222836a6e73677f9440857db8fe40cff8a1b8caa', -690.275, -6.08575, 38.2245, 111.799, 0, 0, 0, 'Boulevard Del Perro Rockford Dr W', 'metro', 0),
(29, 'aa511d65119bba4bec56722548191ad4349c198c', -933.817, -127.573, 37.5776, 117.067, -936.94, -125.126, 37.761, 'Boulevard Del Perro Mad Wayne Thunder Dr SW', 'metro', 0),
(30, 'ec0b93d0e1e2dc9ad7255992c6deb2f92c8181fc', -1521.73, -464.107, 35.3015, 123.086, 0, 0, 0, 'Boulevard Del Perro  SW', 'metro', 0),
(31, '7207c6aa91c72863f8b50192067177f180df2379', -1161.27, -400.291, 35.695, 98.1812, 0, 0, 0, 'Marathon Ave  E', 'metro', 0),
(32, 'bd5ec2670ffaca92d12c1d6879b9fe36aa002cfc', -1407.29, -568.154, 30.3818, 119.23, 0, 0, 0, 'Marathon Ave Prosperity St SW', 'metro', 0),
(33, 'b2c23d2a7d30e074e9943cd5e9d0a1fd4a3359ab', -1482.15, -634.404, 30.3702, 305.049, 0, 0, 0, 'Marathon Ave Bay City Ave NE', 'metro', 0),
(34, 'ff9cd557c0fc46304cff54f22ccdd15aa65bbcdc', -1431.81, -92.8593, 51.6417, 297.942, 0, 0, 0, 'West Eclipse Blvd Dorset Dr W', 'metro', 0),
(35, '21d8995633601b88a27ac76ba0d26600b34950b6', -685.857, -374.013, 34.1945, 249.108, 0, 0, 0, 'Dorset Dr  NW', 'metro', 0),
(36, '34f5903c441dca2ef19f79bde80ef4cf042d2274', -1213.41, -1213.33, 7.59806, 190.893, 0, 0, 0, 'Bay City Ave Invention Ct S', 'metro', 0),
(37, 'b542f14e6f567b0a1f4dd4ba92832b17cfff1fa4', -1170.57, -1468.27, 4.28024, 215.321, 0, 0, 0, 'Magellan Ave Aguja St SE', 'metro', 0),
(38, 'f4ead5267915187b22d9326376bf5ca71f091f2a', 459.736, -625.933, 28.4958, 32.803, 454.38, -615.18, 28.52, 'Dashound Depo', 'terminal', 10),
(39, '7c995589c412b4f09624472d5f0e8ea5c086d613', 955.993, 168.262, 81.6621, 80.9574, 0, 0, 0, 'Vinewood Racetrack', 'terminal', 10),
(40, '8b4eae6b54124cea9621539630f1d5522284c309', 1933.47, 3716.51, 33.2505, 120.577, 1930.27, 3720.55, 32.84, 'Sandy Shores', 'rural', 0),
(41, '4dd8673dccd951a6069c2984c8d7ec350efd6164', 1183, 2691.27, 38.6443, 89.3957, 1178.59, 2701.63, 38.17, 'Grand Senora Desert', 'rural', 0),
(42, '509367a1a16d3c66b82951ded3bc4c0fefa8dc65', 1661.47, 4854.52, 42.7289, 186.474, 0, 0, 0, 'Grapeseed', 'rural', 5),
(43, '62942aa8353bacc3faaad951654267cacf8afa68', -216.221, 6173.25, 32.042, 135.093, 0, 0, 0, 'Great Ocean Hwy Duluoz Ave NE', 'rural', 0),
(44, '6e2ff4d6d66490d6382c40faa4e1db5e91639f42', -158.371, 6203.29, 32.0361, 314.101, 0, 0, 0, 'Great Ocean Hwy  SW', 'rural', 0),
(45, 'b71bbdebedf4c747a9ffaa2f5f9c0edab63b0513', -2531.68, 2343.37, 33.8786, 32.8264, 0, 0, 0, 'Route 68  NW', 'rural', 0),
(46, '11858727cada5fc0aa97afcfae948abe22bb00c6', -1110.78, 2680.36, 19.6074, 130.767, 0, 0, 0, 'Route 68  SW', 'rural', 0),
(47, '24a29b5732704dd632fcbf5bd36542ba31bdde2e', -1050.06, -2541.1, 13.6495, 149.985, 0, 0, 0, 'Air Emu', 'airport', 0),
(48, '6d15f0bb8c17ac3096e9a3aa4df55639b8d026a8', -1018.91, -2732.03, 13.6565, 239.038, 0, 0, 0, 'Los Santos Air', 'airport', 0),
(49, '46f91ccb127b94a46a13613771e86cf655b8a3a1', -620.165, -921.596, 23.2675, 1.94309, 0, 0, 0, 'Palomino Ave Lindsay Circus N', 'metro', 0),
(50, 'a99e87c613aac315a801fb7f11c59726b6600e34', 160.988, -209.049, 54.1357, 249.776, 0, 0, 0, 'Hawick Ave Alta Pl E', 'metro', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `lachee_bus_routes`
--
ALTER TABLE `lachee_bus_routes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lachee_bus_stops`
--
ALTER TABLE `lachee_bus_stops`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hash` (`hash`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `lachee_bus_routes`
--
ALTER TABLE `lachee_bus_routes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `lachee_bus_stops`
--
ALTER TABLE `lachee_bus_stops`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
