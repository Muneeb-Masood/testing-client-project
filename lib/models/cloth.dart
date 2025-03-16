class Cloth {
  // ClothType type;
  DeliveryOption delivery;

  Cloth({
    required this.delivery,
  });

  Map<String, dynamic> toJson() {
    return {
      'delivery': delivery.toString().split('.').last,
    };
  }

  factory Cloth.fromJson(Map<String, dynamic> json) {
    return Cloth(
      delivery: DeliveryOption.values.firstWhere(
        (option) => option.toString().split('.').last == json['delivery'],
      ),
    );
  }
}

enum DeliveryOption {
  mySelf,
  viaAgent,
}

enum ClothType {
  silk,
}
