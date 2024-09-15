library(dplyr)
library(tidyr)
library(googledrive)
library(googlesheets4)

googledrive::drive_auth(path = Sys.getenv('GDRIVE_OPP_MAP_SECRET'))
gs4_auth(token = drive_token())

oblasts <- c("Вінницька", 'Волинська', 'Дніпропетровська', 'Донецька', 
             'Житомирська', 'Закарпатська', 'Запорізька', 'Івано-Франківська', 
             'Київська', 'Кіровоградська', 'Луганська', 'Львівська', 
             'Миколаївська', 'Одеська', 'Полтавська', 'Рівненська', 'Сумська', 
             'Тернопільська', 'Харківська', 'Херсонська', 'Хмельницька', 
             'Черкаська', 'Чернівецька', 'Чернігівська', 'Місто Київ')

today <- as.Date(Sys.Date())

# hromadas

df <- read_sheet("19VCTew0av-AZwmp9GsMicrm2NVh71z9t2_sKgiskMs4")

str(df)

df <- df |> 
  mutate(Географія2 = Географія,
         Сектор2 = Сектор,
         Тип2 = Тип) |>
  separate_longer_delim(Географія2, ", ") |> 
  mutate(oblasts = if_else(Географія2 == "Вся Україна",
                           paste(oblasts, collapse = ", "),
                           Географія2),
         Крайдата = as.Date(Крайдата)) |>
  filter(Крайдата >= today) |>
  separate_longer_delim(oblasts, ", ") |>
  separate_longer_delim(Тип2, ", ") |>
  separate_longer_delim(Сектор2, ", ") |> select(-Географія2) 


# business 

df2 <- read_sheet("1OkjAD1J5YhUUl28dLtZ3_9_AsYgiFdx3wgswbFYZTiY")

df2 <- df2 |>
  mutate(Географія2 = Географія,
         Тип2 = Тип) |>
  separate_longer_delim(Географія2, ", ") |> 
  mutate(oblasts = if_else(Географія2 == "Вся Україна",
                           paste(oblasts, collapse = ", "),
                           Географія2),
         Крайдата = as.Date(Крайдата)) |>
  filter(Крайдата >= today) |>
  separate_longer_delim(oblasts, ", ") |>
  separate_longer_delim(Тип2, ", ") |>
  select(-Географія2) |>
  rename_with(.fn = ~ paste0("biz_", .x), .cols = everything())

# writing transformed data to gs

write_sheet(df, 
            ss = "1SjBwojEyG9D2KD771TQmA1sOcsyUJty8FEfyh0qWkIU", 
            sheet = "hromadas")

write_sheet(df2, 
            ss = "1SjBwojEyG9D2KD771TQmA1sOcsyUJty8FEfyh0qWkIU", 
            sheet = "business")


