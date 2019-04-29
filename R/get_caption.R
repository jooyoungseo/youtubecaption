#' get_caption
#' @title Obtaining YouTube video caption/subtitle in a tidy tibble form.

#' @aliases get_caption
#' @keywords get_caption

#' @description Use this function for downloading a desired YouTube video caption in a tidy tibble data_frame form and save it as an Excel file in your current working directory.

#' @export get_caption
#' @param url A string value for a single YouTube video link URL. A typical form should start with "https://www.youtube.com/watch?v=" followed by a unique video ID.
#' @param savexl A logical value for determining whether or not to save the obtained tidy YouTube caption data as an Excel file. The default is FALSE which does not save it as a file. If set to TRUE, a file named "YouTube_caption_`videoID`.xlsx" is saved in your specified directory (the default is your current working directory).
#' @param openxl A logical value for determining whether or not to open, if any, the saved YouTube_caption Excel file in your working directory. The default is FALSE. TRUE works only when the preceding argument (i.e., savexl) is set to TRUE.
#' @param path A character vector of full path names; the default corresponds to the working directory, \link[base]{getwd}. Tilde expansion (see \link[base]{path.expand}) is performed. Missing values will be ignored.

#' @details
#' See example below.

#' @return tibble (advanced data.frame) object for a YouTube video caption will be returned.

#' @examples
#' \donttest{
#' library(youtubecaption)
#' # Let's get the video caption out of Hadley Wickham's "You can't do data science in a GUI":
#' url <- "https://www.youtube.com/watch?v=cpbtcsGE0OA"
#' caption <- get_caption(url)
#' caption
#' 
#' # Save the caption as an Excel file and open it right it away
#' ## Changing path to temp for the demonstration purpose only:
#' get_caption(url = url, savexl = TRUE, openxl = TRUE, path = tempdir())
#' }

#' @author JooYoung Seo, \email{jooyoung@psu.edu}
#' @author Soyoung Choi, \email{sxc940@psu.edu}

#' @references \url{https://pypi.org/project/youtube-transcript-api/}

get_caption <-
function(url = NULL, savexl = FALSE, openxl = FALSE, path = ".") {  # Function starts:

  if(is.null(url)) {
    stop("Please pass the first argument (YouTube Video URL).")
  } else {

	envnm <- "R_youtube_caption"

	tryCatch({
		if (!(envnm %in% reticulate::conda_list()$name)) {
			reticulate::conda_create(envnm, packages = c("python=3.7.3"), conda = "auto")
		}
	},
	error = function(e) {
		stop("Need to install Anaconda from https://www.anaconda.com/download/.")
	},
	finally = {
		reticulate::use_condaenv(envnm, required = TRUE)
			if (!reticulate::py_module_available("youtube_transcript_api")) {
				reticulate::conda_install(envnm, packages = c('youtube-transcript-api'), pip = TRUE)
			}
		})

    if(stringr::str_detect(url, "youtube[.]com/watch[?]v=")) {
      vid <- unlist(stringr::str_split(url, "[?]v="))[2]

      l <- reticulate::import("youtube_transcript_api")$YouTubeTranscriptApi$get_transcripts(list(vid))

      caption_df <- l[[1]][[1]] %>%
      purrr::map_dfr(~tibble::as_tibble(.)) %>%
      tibble::rowid_to_column("segment_id") %>%
      dplyr::mutate(vid = vid)

      if(savexl) {
        file_name <- paste0(path, "/YT_caption_", vid, ".xlsx")
        writexl::write_xlsx(caption_df, file_name)
      }

	tryCatch({
      if(openxl) {
          if(file.exists(file_name)) {
        utils::browseURL(file_name)
        }
      }
	},
	error = function(e) {
        warning("You have not saved the caption file yet. Use TRUE for 'savexl' (the second argument) in advance.")		
	},
	finally = {
      return(caption_df)
		})

    } else {
      stop("Please make sure the provided URL is valid YouTube video link. Play/channel list is not acceptable.")
    }
  }
}  # Function ends.
