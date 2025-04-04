mclapply2 <- function(..., nb_cores = NULL) {
  if (is.null(nb_cores)) nb_cores <- parallel::detectCores() - 1
  parallel::mclapply(..., mc.cores = nb_cores)
}

#######################################################################################

file_exists <- function(x) file.exists(paste0(data_path, "cache/", x))
readRDS2 <- function(x) readRDS(paste0(data_path, "cache/", x))
saveRDS2 <- function(object, file) saveRDS(object, paste0(data_path, "cache/", file))

if (file_exists("out_parallel.rds")) {
  out_parallel <- readRDS2("out_parallel.rds")
} else {
  out_parallel <- parallel_pipeline(train_data,
                                    seq(35, 42, .5), seq(60, 130, 10), 3:15, 1)
  saveRDS2(out_parallel, "out_parallel.rds")
}

#######################################################################################

second2minute <- function(x) {
  minutes <- floor(x / 60)
  seconds <- x %% 60
  paste0(minutes, "'", seconds)
}


