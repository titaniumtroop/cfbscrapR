#' Team Info Lookup
#' Lists all teams in conference or all D-I teams if conference is left NULL
#' Current support only for D-I
#'
#' @param conference (\emph{String} optional): Conference abbreviation - Select a valid FBS conference\cr
#' Conference abbreviations P5: ACC, B12, B1G, SEC, PAC,\cr
#' Conference abbreviations G5 and FBS Independents: CUSA, MAC, MWC, Ind, SBC, AAC\cr
#' @param only_fbs (\emph{Logical} default TRUE): Filter for only returning FBS teams for a given year.\cr
#' If year is left blank while only_fbs is TRUE, then will return values for most current year
#' @param year (\emph{Integer} optional): Year, 4 digit format (\emph{YYYY}). Filter for getting a list of major division team for a given year
#'
#' @return A data frame with 12 variables:
#' \describe{
#'   \item{\code{team_id}}{integer.}
#'   \item{\code{school}}{character.}
#'   \item{\code{mascot}}{character.}
#'   \item{\code{abbreviation}}{character.}
#'   \item{\code{alt_name1}}{character.}
#'   \item{\code{alt_name2}}{character.}
#'   \item{\code{alt_name3}}{character.}
#'   \item{\code{conference}}{character.}
#'   \item{\code{division}}{character.}
#'   \item{\code{color}}{character.}
#'   \item{\code{alt_color}}{character.}
#'   \item{\code{logos}}{list.}
#' }
#' @source \url{https://api.collegefootballdata.com/teams}
#' @keywords Teams
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom utils URLencode
#' @importFrom assertthat assert_that
#' @importFrom dplyr rename 
#' @export
#' @examples
#'
#' cfb_team_info(conference = "SEC")
#'
#' cfb_team_info(conference = "Ind")
#'
#' cfb_team_info(year = 2019)
#'

cfb_team_info <- function(conference = NULL, only_fbs = TRUE, year = NULL) {

  if(!is.null(conference)){
    # # Check conference parameter in conference abbreviations, if not NULL
    # assertthat::assert_that(conference %in% cfbscrapR::cfb_conf_types_df$abbreviation,
    #             msg = "Incorrect conference abbreviation, potential misspelling.\nConference abbreviations P5: ACC, B12, B1G, SEC, PAC\nConference abbreviations G5 and Independents: CUSA, MAC, MWC, Ind, SBC, AAC")
    # Encode conference parameter for URL, if not NULL
    conference = utils::URLencode(conference, reserved = TRUE)

    base_url <-"https://api.collegefootballdata.com/teams?"

    full_url <- paste0(base_url,
                       "conference=",  conference)
    # Check for internet
    check_internet()

    # Create the GET request and set response as res
    res <- httr::GET(full_url)

    # Check the result
    check_status(res)

    # Get the content and return it as data.frame
    df = jsonlite::fromJSON(full_url) %>% 
      dplyr::rename(team_id = .data$id) %>% 
      as.data.frame()

    return(df)
  }else{

    if(!is.null(year)){
      # Check if year is numeric, if not NULL
      assertthat::assert_that(is.numeric(year) & nchar(year) == 4,
                  msg='Enter valid year as a number (YYYY)')
    }

    base_url <- "https://api.collegefootballdata.com/teams/fbs?"

    # if they want all fbs
    full_url = paste0(base_url,
                      "year=",year)

    # Check for internet
    check_internet()

    # Create the GET request and set response as res
    res <- httr::GET(full_url)

    # Check the result
    check_status(res)

    # Get the content and return it as data.frame
    df = jsonlite::fromJSON(full_url) %>% 
      dplyr::rename(team_id = .data$id) %>% 
      as.data.frame()

    return(df)
  }
}
