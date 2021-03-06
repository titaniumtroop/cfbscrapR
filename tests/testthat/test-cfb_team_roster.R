context("CFB Team Roster")

x <- cfb_team_roster(2019, team = 'Florida State')

y <- cfb_team_roster(2018, team = 'Texas A&M')

cols <- c("athlete_id", "first_name", "last_name", "weight", "height",
          "jersey", "year", "position","home_city","home_state",
          "home_country","team")

test_that("CFB Team Roster", {
  expect_equal(colnames(x), cols)
  expect_equal(colnames(y), cols)
  expect_s3_class(x, "data.frame")
  expect_s3_class(y, "data.frame")
})