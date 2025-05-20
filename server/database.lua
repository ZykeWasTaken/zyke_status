QueriesExecuted = false

local queries = {
	[[
		CREATE TABLE IF NOT EXISTS `zyke_status` (
			`identifier` VARCHAR(255) NOT NULL,
			`data` MEDIUMTEXT NOT NULL DEFAULT "{}",
			`direct_effects` MEDIUMTEXT NOT NULL DEFAULT "{}",
			UNIQUE (`identifier`)
		);
	]]
}

local totalQueries = #queries
for i = 1, #queries do
	MySQL.query.await(queries[i])
	Z.debug("^3Executed query: " .. i .. "/" .. totalQueries .. ".^7")
end

Z.debug("^2Database initialized successfully.^7")

QueriesExecuted = true