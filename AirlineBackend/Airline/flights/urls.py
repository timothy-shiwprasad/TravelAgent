from django.urls import path
from . import views

urlpatterns = [
    path('get/',views.getFlight,name="flights"),
    path('getVoucher/', views.checkVoucher, name="voucher"),
    path("userflights/",views.usersFlight,name="usersFlight"),
    path('bookflight/',views.bookFlight, name = "bookFlight"),
    path('cancelflight/',views.CancelUserFlight, name="cancelFLight")
]