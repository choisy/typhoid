simulate_distribution <- function(density_curve, n = 1e4, eps = .05) {
  tibble(random_x = runif(n),
         random_y = runif(n, max = (1 + eps) * max(density_curve$y))) |> 
    mutate(density_y = with(density_curve, approx(x, y, random_x)$y)) |> 
    filter(random_y < density_y) |> 
    pull(random_x)
}
