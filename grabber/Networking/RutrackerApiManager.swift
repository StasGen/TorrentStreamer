//
//  RutrackerApiManager.swift
//  grabber
//
//  Created by Станислав К. on 13.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation

struct RutrackerSearchParameters {
    let sortBy: SortBy
    let sort: Sort
    let creationDuration: CreationDuration
    let author: String
    let torrentType: [TorrentType]
    
    
    enum SortBy: String, CaseIterable { //упорядочить по
         case Зарегистрирован = "1"
         case Название_темы = "2"
         case Количество_скачиваний = "4"
         case Количество_сидов = "10"
         case Количество_личей = "11"
         case Размер = "7"
         case Посл_сообщение = "8"
        
        static let key: String = "o"
    }
    
    enum Sort: String { //упорядочить
        case по_возрастанию = "2"
        case по_убыванию = "1"
        
        static let key: String = "s"
    }
    
    enum CreationDuration: String, CaseIterable { //за время
        case disabled = ""
        case за_все_время = "-1"
        case за_сегодня = "1"
        case последние_3_дня = "3"
        case посл_неделю = "7"
        case посл_2_недели = "14"
        case последний_месяц = "32"
        
        static let key: String = "tm"
    }
    
    enum TorrentType: String, CaseIterable {
        case _Зарубежное_кино = "7"
        case Фильмы_2021_2022 = "1950"
        case _HD_Video = "2198"
        case UHD_Video = "1457"
        case _Мультфильмы = "4"
        case _Мультсериалы = "921"
        case _Аниме = "33"
        
        //Сериалі
        case Новинки_и_сериалы_в_стадии_показа = "842"
        case Новинки_и_сериалы_в_стадии_показа_HD = "1803"
        case _Зарубежные_сериалы = "189"
        case Зарубежные_сериалы_HD = "2366"
        case Зарубежные_сериалы_UHD = "119"
        case _Русские_сериалы = "9"
        case Русские_сериалы_HD = "81"
        case _Азиатские_сериалы = "2100"
        case _Сериалы_Латинской_Америки_Турции_Индии = "911"

        static let key: String = "f"
    }
    
    private let authorKey = "pn"
    
    func toDic() -> [String: Any] {
        
        return [
            Sort.key: sort.rawValue,
            SortBy.key: sortBy.rawValue,
            CreationDuration.key: creationDuration.rawValue,
            self.authorKey: author,
            TorrentType.key: torrentType.map { $0.rawValue }
        ]
    }
}

class RutrackerApiManager {
    private let apiService: ApiServiceImpl
    private let htmlParser: Rutracker_org_HtmlParser
    
    init(
        apiService: ApiServiceImpl = ApiServiceFactory.rutracker(),
        htmlParser: Rutracker_org_HtmlParser = Rutracker_org_HtmlParser()
    ) {
        self.apiService = apiService
        self.htmlParser = htmlParser
    }
    
    func login(login: String, password: String, completion: @escaping () -> ()) {
        let token = ApiServiceToken(
            path: "/login.php",
            parameters: [
                "login_username": "malkozoz",
                "login_password": "canoni250",
                "login": "Вход"
            ],
            method: .post
        )
        apiService.makeStringRequest(token: token) { result in
            completion()
        }
    }
    
    func getTrackers(searchText: String, parameters: RutrackerSearchParameters, completion: @escaping (Result<[TorrentPreviewModel], Error>) -> Void) {
        let token = ApiServiceToken(
            path: "/tracker.php",
            queryItems: ["nm" : searchText],
            parameters: parameters.toDic(),
//                RutrackerSearchParameters(
//                    sortBy: .Зарегистрирован,
//                    sort: .по_возрастанию,
//                    creationDuration: .disabled,
//                    author: "",
//                    torrentType: [.Видео]
//                ).toDic(),
            method: .post
        )
        apiService.makeStringRequest(token: token) { [htmlParser] result in
            if let html = result.value {
                let trackers = htmlParser.trackers(html: html)
                completion(.success(trackers))
            } else {
                completion(.failure(NSError()))
            }
        }
    }
    
    func getTrackerInfo(id: String, completion: @escaping (Result<TorrentDetailModel, Error>) -> Void) {
        let token = ApiServiceToken(
            path: "/viewtopic.php",
            queryItems: ["t" : id],
            method: .post
        )
        apiService.makeStringRequest(token: token) { [htmlParser] result in
            if
                let html = result.value,
                let tracker = htmlParser.trackerDetail(html: html)
            {
                completion(.success(tracker))
            } else {
                completion(.failure(NSError()))
            }
        }
    }
    
    func getTorrentFile(topicId: String, completion: @escaping (Swift.Result<Data, Error>) -> Void) {
        let token = ApiServiceToken(
            path: "/dl.php",
            queryItems: ["t" : topicId],
            method: .post
        )
        apiService.makeDataRequest(token: token) { result in
            do {
                let data: Data = try result.unwrap()
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
        /*
         favorites -> https://rutracker.org/forum/bookmarks.php
         addToFavorites -> ...
         
         
         */
}



//   Сериалы">
//9        Русские сериалы
//81        |- Русские сериалы (HD Video)
//920       |- Русские сериалы (DVD Video)
//189      Зарубежные сериалы
//842       |- Новинки и сериалы в стадии показа
//235       |- Сериалы США и Канады
//242       |- Сериалы Великобритании и Ирландии
//819       |- Скандинавские сериалы
//1531      |- Испанские сериалы
//721       |- Итальянские сериалы
//1102      |- Европейские сериалы
//1120      |- Сериалы стран Африки, Ближнего и Среднего Востока
//1214      |- Сериалы Австралии и Новой Зеландии
//489       |- Сериалы Ближнего Зарубежья
//387       |- Сериалы совместного производства нескольких стран
//1359      |- Веб-сериалы, Вебизоды к сериалам и Пилотные серии сериалов
//195       |- Для некондиционных раздач
//2366     Зарубежные сериалы (HD Video)
//119       |- Зарубежные сериалы (UHD Video)

//911      Сериалы Латинской Америки, Турции и Индии
//1493      |- Актёры и актрисы латиноамериканских сериалов
//325       |- Сериалы Аргентины
//534       |- Сериалы Бразилии
//594       |- Сериалы Венесуэлы
//1301      |- Сериалы Индии
//607       |- Сериалы Колумбии
//1574      |- Сериалы Латинской Америки с озвучкой (раздачи папками)
//1539      |- Сериалы Латинской Америки с субтитрами
//1940      |- Официальные краткие версии сериалов Латинской Америки
//694       |- Сериалы Мексики
//775       |- Сериалы Перу, Сальвадора, Чили и других стран
//781       |- Сериалы совместного производства
//718       |- Сериалы США (латиноамериканские)
//704       |- Сериалы Турции
//1537      |- Для некондиционных раздач
//2100     Азиатские сериалы
//915       |- Корейские сериалы
//1242      |- Корейские сериалы (HD Video)
//717       |- Китайские сериалы
//1939      |- Японские сериалы
//2412      |- Сериалы Таиланда, Индонезии, Сингапура
//2102      |- VMV и др. ролики



    // Кино, Видео и ТВ">
//"22"    >Наше кино
//"941"   > |- Кино СССР
//"1666"  > |- Детские отечественные фильмы
//"376"   > |- Авторские дебюты
//"106"   > |- Фильмы России и СССР на национальных языках [без перевода]
//"7"     >Зарубежное кино
//"187"   > |- Классика мирового кинематографа
//"2090"  > |- Фильмы до 1990 года
//"2221"  > |- Фильмы 1991-2000
//"2091"  > |- Фильмы 2001-2005
//"2092"  > |- Фильмы 2006-2010
//"2093"  > |- Фильмы 2011-2015
//"2200"  > |- Фильмы 2016-2020
//"1950"  > |- Фильмы 2021-2022
//"2540"  > |- Фильмы Ближнего Зарубежья
//"934"   > |- Азиатские фильмы
//"505"   > |- Индийское кино
//"212"   > |- Сборники фильмов
//"2459"  > |- Короткий метр
//"1235"  > |- Грайндхаус
//"166"   > |- Зарубежные фильмы без перевода
//"185"   > |- Звуковые дорожки и Переводы
//"124"   >Арт-хаус и авторское кино
//"1543"  > |- Короткий метр (Арт-хаус и авторское кино)
//"709"   > |- Документальные фильмы (Арт-хаус и авторское кино)
//"1577"  > |- Анимация (Арт-хаус и авторское кино)
//"511"   >Театр
//"93"    >DVD Video
//"905"   > |- Классика мирового кинематографа (DVD Video)
//"101"   > |- Зарубежное кино (DVD Video)
//"100"   > |- Наше кино (DVD Video)
//"877"   > |- Фильмы Ближнего Зарубежья (DVD Video)
//"1576"  > |- Азиатские фильмы (DVD Video)
//"572"   > |- Арт-хаус и авторское кино (DVD Video)
//"2220"  > |- Индийское кино (DVD Video)
//"1670"  > |- Грайндхаус (DVD Video)
//"2198"  >HD Video
//"1457"  > |- UHD Video
//"2199"  > |- Классика мирового кинематографа (HD Video)
//"313"   > |- Зарубежное кино (HD Video)
//"312"   > |- Наше кино (HD Video)
//"1247"  > |- Фильмы Ближнего Зарубежья (HD Video)
//"2201"  > |- Азиатские фильмы (HD Video)
//"2339"  > |- Арт-хаус и авторское кино (HD Video)
//"140"   > |- Индийское кино (HD Video)
//"194"   > |- Грайндхаус (HD Video)
//"352"   >3D/Стерео Кино, Видео, TV и Спорт
//"549"   > |- 3D Кинофильмы
//"1213"  > |- 3D Мультфильмы
//"2109"  > |- 3D Документальные фильмы
//"514"   > |- 3D Спорт
//"2097"  > |- 3D Ролики, Музыкальное видео, Трейлеры к фильмам
//"4"     >Мультфильмы
//"84"    > |- Мультфильмы (UHD Video)
//"2343"  > |- Отечественные мультфильмы (HD Video)
//"930"   > |- Иностранные мультфильмы (HD Video)
//"2365"  > |- Иностранные короткометражные мультфильмы (HD Video)
//"1900"  > |- Отечественные мультфильмы (DVD)
//"2258"  > |- Иностранные короткометражные мультфильмы (DVD)
//"521"   > |- Иностранные мультфильмы (DVD)
//"208"   > |- Отечественные мультфильмы
//"539"   > |- Отечественные полнометражные мультфильмы
//"209"   > |- Иностранные мультфильмы
//"484"   > |- Иностранные короткометражные мультфильмы
//"822"   > |- Сборники мультфильмов
//"181"   > |- Мультфильмы без перевода
//"921"   >Мультсериалы
//"815"   > |- Мультсериалы (SD Video)
//"816"   > |- Мультсериалы (DVD Video)
//"1460"  > |- Мультсериалы (HD Video)
//"33"    >Аниме
//"1105"  > |- Аниме (HD Video)
//"599"   > |- Аниме (DVD)
//"1389"  > |- Аниме (основной подраздел)
//"1391"  > |- Аниме (плеерный подраздел)
//"2491"  > |- Аниме (QC подраздел)
//"2544"  > |- Ван-Пис
//"1642"  > |- Гандам
//"1390"  > |- Наруто
//"404"   > |- Покемоны
//"893"   > |- Японские мультфильмы
//"809"   > |- Звуковые дорожки (Аниме)
//"2484"  > |- Артбуки и журналы (Аниме)
//"1386"  > |- Обои, сканы, аватары, арт




