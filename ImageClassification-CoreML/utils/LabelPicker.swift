//
//  LabelPicker.swift
//  ImageClassification-CNN-iOS
//
//  Created by 이종하 on 10/5/24.
//  Copyright © 2024 JoyLee. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class LabelPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    private let toolbar = UIToolbar()
    private var selectedLabel: String?
    var didSelectLabel: ((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pickerView)

        pickerView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        // UIToolbar 설정
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        toolbar.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
    }

    // 선택된 항목을 담을 리스트
    let labelList = [
        "dining table, board",
        "tench, Tinca tinca",
        "goldfish, Carassius auratus",
        "great white shark, white shark, man-eater, man-eating shark, Carcharodon carcharias",
        "tiger shark, Galeocerdo cuvieri",
        "hammerhead, hammerhead shark",
        "electric ray, crampfish, numbfish, torpedo",
        "electric fan, blower",
        "stingray",
        "cock",
        "hen",
        "ostrich, Struthio camelus",
        "brambling, Fringilla montifringilla",
        "goldfinch, Carduelis carduelis",
        "house finch, linnet, Carpodacus mexicanus",
        "junco, snowbird",
        "indigo bunting, indigo finch, indigo bird, Passerina cyanea",
        "robin, American robin, Turdus migratorius",
        "bulbul",
        "jay",
        "magpie",
        "chickadee",
        "water ouzel, dipper",
        "kite",
        "bald eagle, American eagle, Haliaeetus leucocephalus",
        "vulture",
        "great grey owl, great gray owl, Strix nebulosa",
        "European fire salamander, Salamandra salamandra",
        "common newt, Triturus vulgaris",
        "eft",
        "spotted salamander, Ambystoma maculatum",
        "axolotl, mud puppy, Ambystoma mexicanum",
        "bullfrog, Rana catesbeiana",
        "tree frog, tree-frog",
        "tailed frog, bell toad, ribbed toad, tailed toad, Ascaphus trui",
        "loggerhead, loggerhead turtle, Caretta caretta",
        "leatherback turtle, leatherback, leathery turtle, Dermochelys coriacea",
        "mud turtle",
        "terrapin",
        "box turtle, box tortoise",
        "banded gecko",
        "common iguana, iguana, Iguana iguana",
        "American chameleon, anole, Anolis carolinensis",
        "whiptail, whiptail lizard",
        "agama",
        "frilled lizard, Chlamydosaurus kingi",
        "alligator lizard",
        "Gila monster, Heloderma suspectum",
        "green lizard, Lacerta viridis",
        "African chameleon, Chamaeleo chamaeleon",
        "Komodo dragon, Komodo lizard, dragon lizard, giant lizard, Varanus komodoensis",
        "African crocodile, Nile crocodile, Crocodylus niloticus",
        "American alligator, Alligator mississipiensis",
        "triceratops",
        "thunder snake, worm snake, Carphophis amoenus",
        "ringneck snake, ring-necked snake, ring snake",
        "hognose snake, puff adder, sand viper",
        "green snake, grass snake",
        "king snake, kingsnake",
        "garter snake, grass snake",
        "water snake",
        "vine snake",
        "night snake, Hypsiglena torquata",
        "boa constrictor, Constrictor constrictor",
        "rock python, rock snake, Python sebae",
        "Indian cobra, Naja naja",
        "green mamba",
        "sea snake",
        "horned viper, cerastes, sand viper, horned asp, Cerastes cornutus",
        "diamondback, diamondback rattlesnake, Crotalus adamanteus",
        "sidewinder, horned rattlesnake, Crotalus cerastes",
        "trilobite",
        "harvestman, daddy longlegs, Phalangium opilio",
        "scorpion",
        "black and gold garden spider, Argiope aurantia",
        "barn spider, Araneus cavaticus",
        "garden spider, Aranea diademata",
        "black widow, Latrodectus mactans",
        "tarantula",
        "wolf spider, hunting spider",
        "tick",
        "centipede",
        "black grouse",
        "ptarmigan",
        "ruffed grouse, partridge, Bonasa umbellus",
        "prairie chicken, prairie grouse, prairie fowl",
        "peacock",
        "quail",
        "partridge",
        "African grey, African gray, Psittacus erithacus",
        "macaw",
        "sulphur-crested cockatoo, Kakatoe galerita, Cacatua galerita",
        "lorikeet",
        "coucal",
        "bee eater",
        "hornbill",
        "hummingbird",
        "jacamar",
        "toucan",
        "drake",
        "red-breasted merganser, Mergus serrator",
        "goose",
        "black swan, Cygnus atratus",
        "tusker",
        "echidna, spiny anteater, anteater",
        "platypus, duckbill, duckbilled platypus, duck-billed platypus, Ornithorhynchus anatinus",
        "wallaby, brush kangaroo",
        "koala, koala bear, kangaroo bear, native bear, Phascolarctos cinereus",
        "wombat",
        "jellyfish",
        "sea anemone, anemone",
        "brain coral",
        "flatworm, platyhelminth",
        "nematode, nematode worm, roundworm",
        "conch",
        "snail",
        "slug",
        "sea slug, nudibranch",
        "chiton, coat-of-mail shell, sea cradle, polyplacophore",
        "chambered nautilus, pearly nautilus, nautilus",
        "Dungeness crab, Cancer magister",
        "rock crab, Cancer irroratus",
        "fiddler crab",
        "king crab, Alaska crab, Alaskan king crab, Alaska king crab, Paralithodes camtschaticus",
        "American lobster, Northern lobster, Maine lobster, Homarus americanus",
        "spiny lobster, langouste, rock lobster, crawfish, crayfish, sea crawfish",
        "crayfish, crawfish, crawdad, crawdaddy",
        "hermit crab",
        "isopod",
        "white stork, Ciconia ciconia",
        "black stork, Ciconia nigra",
        "spoonbill",
        "flamingo",
        "little blue heron, Egretta caerulea",
        "American egret, great white heron, Egretta albus",
        "bittern",
        "crane, bird",
        "limpkin, Aramus pictus",
        "European gallinule, Porphyrio porphyrio",
        "American coot, marsh hen, mud hen, water hen, Fulica americana",
        "bustard",
        "ruddy turnstone, Arenaria interpres",
        "red-backed sandpiper, dunlin, Erolia alpina",
        "redshank, Tringa totanus",
        "dowitcher",
        "oystercatcher, oyster catcher",
        "pelican",
        "king penguin, Aptenodytes patagonica",
        "albatross, mollymawk",
        "grey whale, gray whale, devilfish, Eschrichtius gibbosus, Eschrichtius robustus",
        "killer whale, killer, orca, grampus, sea wolf, Orcinus orca",
        "dugong, Dugong dugon",
        "sea lion",
        "Chihuahua",
        "Japanese spaniel",
        "Maltese dog, Maltese terrier, Maltese",
        "Pekinese, Pekingese, Peke",
        "Shih-Tzu",
        "Blenheim spaniel",
        "papillon",
        "toy terrier",
        "Rhodesian ridgeback",
        "Afghan hound, Afghan",
        "basset, basset hound",
        "beagle",
        "bloodhound, sleuthhound",
        "bluetick",
        "black-and-tan coonhound",
        "Walker hound, Walker foxhound",
        "English foxhound",
        "redbone",
        "borzoi, Russian wolfhound",
        "Irish wolfhound",
        "Italian greyhound",
        "whippet",
        "Ibizan hound, Ibizan Podenco",
        "Norwegian elkhound, elkhound",
        "otterhound, otter hound",
        "Saluki, gazelle hound",
        "Scottish deerhound, deerhound",
        "Weimaraner",
        "Staffordshire bullterrier, Staffordshire bull terrier",
        "American Staffordshire terrier, Staffordshire terrier, American pit bull terrier, pit bull terrier",
        "Bedlington terrier",
        "Border terrier",
        "Kerry blue terrier",
        "Irish terrier",
        "Norfolk terrier",
        "Norwich terrier",
        "Yorkshire terrier",
        "wire-haired fox terrier",
        "Lakeland terrier",
        "Sealyham terrier, Sealyham",
        "Airedale, Airedale terrier",
        "cairn, cairn terrier",
        "Australian terrier",
        "Dandie Dinmont, Dandie Dinmont terrier",
        "Boston bull, Boston terrier",
        "miniature schnauzer",
        "giant schnauzer",
        "standard schnauzer",
        "Scotch terrier, Scottish terrier, Scottie",
        "Tibetan terrier, chrysanthemum dog",
        "silky terrier, Sydney silky",
        "soft-coated wheaten terrier",
        "West Highland white terrier",
        "Lhasa, Lhasa apso",
        "flat-coated retriever",
        "curly-coated retriever",
        "golden retriever",
        "Labrador retriever",
        "Chesapeake Bay retriever",
        "German short-haired pointer",
        "vizsla, Hungarian pointer",
        "English setter",
        "Irish setter, red setter",
        "Gordon setter",
        "Brittany spaniel",
        "clumber, clumber spaniel",
        "English springer, English springer spaniel",
        "Welsh springer spaniel",
        "cocker spaniel, English cocker spaniel, cocker",
        "Sussex spaniel",
        "Irish water spaniel",
        "kuvasz",
        "schipperke",
        "groenendael",
        "malinois",
        "briard",
        "kelpie",
        "komondor",
        "Old English sheepdog, bobtail",
        "Shetland sheepdog, Shetland sheep dog, Shetland",
        "collie",
        "Border collie",
        "Bouvier des Flandres, Bouviers des Flandres",
        "Rottweiler",
        "German shepherd, German shepherd dog, German police dog, alsatian",
        "Doberman, Doberman pinscher",
        "miniature pinscher",
        "Greater Swiss Mountain dog",
        "Bernese mountain dog",
        "Appenzeller",
        "EntleBucher",
        "boxer",
        "bull mastiff",
        "Tibetan mastiff",
        "French bulldog",
        "Great Dane",
        "Saint Bernard, St Bernard",
        "Eskimo dog, husky",
        "malamute, malemute, Alaskan malamute",
        "Siberian husky",
        "dalmatian, coach dog, carriage dog",
        "affenpinscher, monkey pinscher, monkey dog",
        "basenji",
        "pug, pug-dog",
        "Leonberg",
        "Newfoundland, Newfoundland dog",
        "Great Pyrenees",
        "Samoyed, Samoyede",
        "Pomeranian",
        "chow, chow chow",
        "keeshond",
        "Brabancon griffon",
        "Pembroke, Pembroke Welsh corgi",
        "Cardigan, Cardigan Welsh corgi",
        "toy poodle",
        "miniature poodle",
        "standard poodle",
        "Mexican hairless",
        "timber wolf, grey wolf, gray wolf, Canis lupus",
        "white wolf, Arctic wolf, Canis lupus tundrarum",
        "red wolf, maned wolf, Canis rufus, Canis niger",
        "coyote, prairie wolf, brush wolf, Canis latrans",
        "dingo, warrigal, warragal, Canis dingo",
        "dhole, Cuon alpinus",
        "African hunting dog, hyena dog, Cape hunting dog, Lycaon pictus",
        "hyena, hyaena",
        "red fox, Vulpes vulpes",
        "kit fox, Vulpes macrotis",
        "Arctic fox, white fox, Alopex lagopus",
        "grey fox, gray fox, Urocyon cinereoargenteus",
        "tabby, tabby cat",
        "tiger cat",
        "Persian cat",
        "Siamese cat, Siamese",
        "Egyptian cat",
        "cougar, puma, catamount, mountain lion, painter, panther, Felis concolor",
        "lynx, catamount",
        "leopard, Panthera pardus",
        "snow leopard, ounce, Panthera uncia",
        "jaguar, panther, Panthera onca, Felis onca",
        "lion, king of beasts, Panthera leo",
        "tiger, Panthera tigris",
        "cheetah, chetah, Acinonyx jubatus",
        "brown bear, bruin, Ursus arctos",
        "American black bear, black bear, Ursus americanus, Euarctos americanus",
        "ice bear, polar bear, Ursus Maritimus, Thalarctos maritimus",
        "sloth bear, Melursus ursinus, Ursus ursinus",
        "mongoose",
        "meerkat, mierkat",
        "tiger beetle",
        "ladybug, ladybeetle, lady beetle, ladybird, ladybird beetle",
        "ground beetle, carabid beetle",
        "long-horned beetle, long", "toilet seat"].sorted()

    // UIPickerViewDataSource 메서드: 열의 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // UIPickerViewDataSource 메서드: 행의 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return labelList.count
    }

    // UIPickerViewDelegate 메서드: 행에 표시할 항목
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labelList[row]
    }

    // UIPickerViewDelegate 메서드: 항목 선택 시 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLabel = labelList[row]
    }

    // 완료 버튼 클릭 시 호출
    @objc func doneButtonTapped() {
        if let selectedLabel = selectedLabel {
            print("Selected Label: \(selectedLabel)")
            didSelectLabel?(selectedLabel) // 클로저를 통해 선택된 값을 전달
        } else {
            print("No item selected")
            didSelectLabel?(labelList.first ?? "")
        }
        dismiss(animated: true, completion: nil)
    }
}
