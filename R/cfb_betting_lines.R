#' Get Betting information from games
#'
#' @param game_id (\emph{Integer} optional): Game ID filter for querying a single game
#' Can be found using the \code{\link[cfbscrapR:cfb_game_info]{cfbscrapR::cfb_game_info()}} function
#' @param year (\emph{Integer} required): Year, 4 digit format(\emph{YYYY})
#' @param week (\emph{Integer} optional): Week - values from 1-15, 1-14 for seasons pre-playoff (i.e. 2013 or earlier)
#' @param season_type (\emph{String} default regular): Select Season Type: regular or postseason
#' @param team (\emph{String} optional): D-I Team
#' @param home_team (\emph{String} optional): Home D-I Team
#' @param away_team (\emph{String} optional): Away D-I Team
#' @param conference (\emph{String} optional): Conference abbreviation - Select a valid FBS conference\cr
#' Conference abbreviations P5: ACC, B12, B1G, SEC, PAC\cr
#' Conference abbreviations G5 and FBS Independents: CUSA, MAC, MWC, Ind, SBC, AAC\cr
#' @param line_provider (\emph{String} optional): Select Line Provider - Caesars, consensus, numberfire, or teamrankings
#' 
#' @return Betting information for games with the following columns:
#' \describe{
#'   \item{\code{game_id}}{integer. Unique game identifier - `game_id`.}
#'   \item{\code{season}}{integer. Season parameter.}
#'   \item{\code{season_type}}{character. Season Type (regular, postseason, both).}
#'   \item{\code{week}}{integer. Week, values from 1-15, 1-14 for seasons pre-playoff (i.e. 2013 or earlier).}
#'   \item{\code{home_team}}{character. Home D-I Team.}
#'   \item{\code{home_conference}}{character. Home D-I Conference.}
#'   \item{\code{home_score}}{integer. Home Score.}
#'   \item{\code{away_team}}{character. Away D-I Team.}
#'   \item{\code{away_conference}}{character. Away D-I Conference.}
#'   \item{\code{away_score}}{integer. Away Score.}
#'   \item{\code{provider}}{character. Line provider.}
#'   \item{\code{spread}}{character. Spread for the game.}
#'   \item{\code{formatted_spread}}{character. Formatted spread for the game.}
#'   \item{\code{over_under}}{character. Over/Under for the game.}
#' }
#' @source \url{https://api.collegefootballdata.com/lines}
#' @keywords Betting Lines
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom utils URLencode
#' @importFrom assertthat assert_that
#' @importFrom janitor clean_names
#' @importFrom glue glue
#' @importFrom purrr map_if
#' @importFrom dplyr filter as_tibble rename
#' @importFrom tidyr unnest
#' @export
#' @examples
#'
#' cfb_betting_lines(year = 2018, week = 12, team = 'Florida State')
#'
#' #7 OTs LSU at TAMU
#' cfb_betting_lines(year = 2018, week = 13, team = "Texas A&M", conference = 'SEC')
#'

cfb_betting_lines <- function(game_id = NULL,
                              year = NULL,
                              week = NULL,
                              season_type = 'regular',
                              team = NULL,
                              home_team = NULL,
                              away_team = NULL,
                              conference = NULL,
                              line_provider = NULL) {
  
  if(!is.null(game_id)){
    # Check if game_id is numeric, if not NULL
    assertthat::assert_that(is.numeric(game_id),
                msg = 'Enter valid game_id (numeric value)')
  }
  if(!is.null(year)){
    # Check if year is numeric, if not NULL
    assertthat::assert_that(is.numeric(year) & nchar(year) == 4,
                msg = 'Enter valid year as a number (YYYY)')
  }
  if(!is.null(week)){
    # Check if week is numeric, if not NULL
    assertthat::assert_that(is.numeric(week) & nchar(week) <= 2,
                msg = 'Enter valid week 1-15\n(14 for seasons pre-playoff, i.e. 2014 or earlier)')
  }
  if(season_type != 'regular'){
    # Check if season_type is appropriate, if not regular
    assertthat::assert_that(season_type %in% c('postseason'),
                msg = 'Enter valid season_type: regular or postseason')
  }
  if(!is.null(team)){
    if(team == "San Jose State"){
      team = utils::URLencode(paste0("San Jos","\u00e9", " State"), reserved = TRUE)
    } else{
      # Encode team parameter for URL if not NULL
      team = utils::URLencode(team, reserved = TRUE)
    }
  }
  if(!is.null(home_team)){
    # Encode home_team parameter for URL, if not NULL
    home_team = utils::URLencode(home_team, reserved = TRUE)
  }
  if(!is.null(away_team)){
    # Encode away_team parameter for URL, if not NULL
    away_team = utils::URLencode(away_team, reserved = TRUE)
  }
  if(!is.null(conference)){
    # # Check conference parameter in conference abbreviations, if not NULL
    # assertthat::assert_that(conference %in% cfbscrapR::cfb_conf_types_df$abbreviation,
    #             msg = "Incorrect conference abbreviation, potential misspelling.\nConference abbreviations P5: ACC, B12, B1G, SEC, PAC\nConference abbreviations G5 and Independents: CUSA, MAC, MWC, Ind, SBC, AAC")
    # Encode conference parameter for URL, if not NULL
    conference = utils::URLencode(conference, reserved = TRUE)
  }
  if(!is.null(line_provider)){
    # Check line_provider parameter is a valid entry
    assertthat::assert_that(line_provider %in% c("Caesars", "consensus", "numberfire", "teamrankings"),
                msg = "Enter valid line provider: Caesars, consensus, numberfire, or teamrankings")
  }
  
  base_url <- "https://api.collegefootballdata.com/lines?"
  
  full_url <- paste0(base_url,
                     "gameId=", game_id,
                     "&year=", year,
                     "&week=", week,
                     "&seasonType=", season_type,
                     "&team=", team,
                     "&home=", home_team,
                     "&away=", away_team,
                     "&conference=", conference)
  
  # Check for internet
  check_internet()
  
  # Create the GET request and set response as res
  res <- httr::GET(full_url)
  
  # Check the result
  check_status(res)
  
  df <- data.frame()
  tryCatch(
    expr = {
      # Get the content and return it as data.frame
      df = jsonlite::fromJSON(full_url, flatten = TRUE) %>%
        purrr::map_if(is.data.frame, list) %>%
        dplyr::as_tibble() %>%
        tidyr::unnest(.data$lines) 
      
      if(!is.null(line_provider)){
        if(is.list(df) & length(df)==0){
          df <- data.frame(game_id = game_id, spread = 0, formatted_spread = "home 0")
        }
        else if(!is.null(df$provider)){
          df <- df %>% 
            dplyr::filter(.data$provider == line_provider) %>% 
            janitor::clean_names() %>% 
            dplyr::rename(game_id = .data$id) %>% 
            as.data.frame()
        }
        else{
          df <- data.frame(game_id = game_id, spread = 0, formatted_spread = "home 0")
        }
      }
      if(is.list(df) & length(df) == 0){
        df <- data.frame(game_id = game_id, spread = 0, formatted_spread = "home 0")
      }else{
        df <- df %>% 
          janitor::clean_names() %>%
          dplyr::rename(game_id = .data$id) %>% 
          as.data.frame()
      }

    },
    error = function(e) {
    },
    warning = function(w) {
    },
    finally = {
    }
  )
  return(df)
}
