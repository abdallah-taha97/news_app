import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/modules/business/business_screen.dart';
import 'package:news_app/modules/sports/sports_screen.dart';
import 'package:news_app/shared/cubit/states.dart';
import 'package:news_app/shared/network/remote/dio_helper.dart';
import 'package:news_app/shared/network/local/cach_helper.dart';

class NewsCubit extends Cubit<NewsStates> {
  NewsCubit() : super(NewsInitialState());

  static NewsCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.business_center_sharp), label: 'Business'),
    BottomNavigationBarItem(
        icon: Icon(Icons.sports_basketball), label: 'Sports'),
  ];
  List<Widget> screens = [
    BusinessScreen(),
    SportsScreen(),
  ];
  void changeBottomNavBar(int index) {
    currentIndex = index;

    emit(NewsBottomNavState());
  }

  List<Map<dynamic, dynamic>> business = [];

  void getBusiness() {
    emit(NewsBusinessLoadingState());
    DioHelper.getData(
      url: 'v2/top-headlines',
      query: {
        'country': 'us',
        'category': 'business',
        'apiKey': '5b6cbfe868d74d7ea998dc3cc00a5979',
      },
    ).then((value) {
      //business = value.data['articles'];
      business = List<Map<String, dynamic>>.from(value.data['articles']);
      print(business[0]['title']);
      emit(NewsGetBusinessSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(NewsGetBusinessErrorState(error.toString()));
    });
  }

  List<Map<dynamic, dynamic>> sports = [];

  void getSports() {
    emit(NewsSportsLoadingState());
    DioHelper.getData(
      url: 'v2/top-headlines',
      query: {
        'country': 'us',
        'category': 'sports',
        'apiKey': '5b6cbfe868d74d7ea998dc3cc00a5979',
      },
    ).then((value) {
      //business = value.data['articles'];
      sports = List<Map<String, dynamic>>.from(value.data['articles']);
      print(sports[0]['title']);
      emit(NewsGetSportsSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(NewsGetSportsErrorState(error.toString()));
    });
  }

  bool isDark = false;

  void changeAppMode({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
      emit(AppChangeModeState());
    } else {
      isDark = !isDark;
      CacheHelper.putData(key: 'isDark', value: isDark).then((value) {
        emit(AppChangeModeState());
      });
    }
  }

  List<dynamic> search = [];

  void getSearch(String value) {
    emit(NewsSearchLoadingState());
    search = [];
    DioHelper.getData(
      url: 'v2/everything',
      query: {
        'q': '$value',
        'apiKey': '5b6cbfe868d74d7ea998dc3cc00a5979',
      },
    ).then((value) {
      //business = value.data['articles'];
      search = List<Map<String, dynamic>>.from(value.data['articles']);
      print(search[0]['title']);
      emit(NewsGetSearchSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(NewsGetSearchErrorState(error.toString()));
    });
  }
}
