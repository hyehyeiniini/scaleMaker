//
//  ViewController.swift
//  ScaleMaker
//
//  Created by Chris lee on 4/13/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // MARK: - 스토리보드로 설정한 것들
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var getTitleButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var shouldPlay = true
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var viewC: UIView!
    @IBOutlet weak var viewD: UIView!
    @IBOutlet weak var viewE: UIView!
    @IBOutlet weak var viewF: UIView!
    @IBOutlet weak var viewG: UIView!
    @IBOutlet weak var viewA: UIView!
    @IBOutlet weak var viewB: UIView!
    
    weak var timer: Timer?
    var player: AVAudioPlayer?
    
    var tempo: Float = 1.0
    lazy var notes = [viewC, viewD, viewE, viewF, viewG, viewA, viewB]
    let colorPalette = [UIColor(red: 0.94, green: 0.62, blue: 0.65, alpha: 1.00),
                        UIColor(red: 0.96, green: 0.79, blue: 0.58, alpha: 1.00),
                        UIColor(red: 0.98, green: 0.98, blue: 0.75, alpha: 1.00),
                        UIColor(red: 0.76, green: 0.92, blue: 0.75, alpha: 1.00),
                        UIColor(red: 0.78, green: 0.79, blue: 1.00, alpha: 1.00),
                        UIColor(red: 0.80, green: 0.67, blue: 0.92, alpha: 1.00),
                        UIColor(red: 0.96, green: 0.76, blue: 0.95, alpha: 1.00)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI 관련 설정
    func configureUI(){
        // 버튼 둥글게 처리
        getTitleButton.layer.cornerRadius = 5
        getTitleButton.clipsToBounds = true
        playButton.layer.cornerRadius = 5
        playButton.clipsToBounds = true
        
        // 텍스트필드 설정
        titleTextField.delegate = self
        titleTextField.placeholder = "제목을 입력하세요."
        
        // 경고 메세지 설정
        warningLabel.textColor = .clear
        
        // 버튼 타이틀 설정
        playButton.setTitle("Play", for: .normal)
        
        // 음계 동그라미 모양 설정
        for i in 0...6 {
            guard let view = notes[i] else { return }
            view.clipsToBounds = true
            view.layer.cornerRadius = view.frame.height / 2.0
        }
    }
    
    // MARK: - 입력 버튼 눌렀을 때 처리
    @IBAction func getTitleButtonTapped(_ sender: UIButton) {
        // 아무것도 입력하지 않았을 때 경고문구 띄우기
        if titleTextField.text == "" {
            warningLabel.textColor = .red
            warningLabel.text = "제목을 한 글자 이상 입력하세요."
            return
        }
        songTitleLabel.text = titleTextField.text
    }
    
    // MARK: - 슬라이더 눌렀을 때 처리
    @IBAction func sliderChanged(_ sender: UISlider) {
        tempo = sender.value
    }
    
    // MARK: - 시작 버튼 눌렀을 때 처리
    @IBAction func playButtonTapped(_ sender: UIButton) {
        // 시작 -> 정지 버튼으로
        if shouldPlay == true{
            timer?.invalidate()
            
            // 슬라이더 비활성화
            slider.isEnabled = false
            // 버튼 타이틀 변경
            playButton.setTitle("Stop", for: .normal)
            
            var notesIndex = 0
            var prevNotesIndex: Int?
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(tempo), repeats: true) { [self] _ in
                // 재생해야 할 음계 설정 -> tempo 간격으로 변화
                notesIndex %= 7
                
                // 음계 재생
                playNotes(idx: notesIndex)
                
                // UI 관련 설정
                notes[notesIndex]!.backgroundColor = colorPalette[notesIndex]
                if let prevNotesIndex = prevNotesIndex {
                    notes[prevNotesIndex]!.backgroundColor = .systemGray2
                }
                
                // 인덱스 설정
                prevNotesIndex = notesIndex
                notesIndex += 1
            }
            shouldPlay.toggle()
            
        } 
        // 정지 -> 시작 버튼으로
        else {
            timer?.invalidate()
            
            // 슬라이더 활성화 및 초기화
            slider.isEnabled = true
            slider.setValue(0.5, animated: true)
            
            // 버튼 타이틀 변경
            playButton.setTitle("Play", for: .normal)
            
            // 음계 색 초기화
            for i in 0...6 {
                notes[i]?.backgroundColor = .systemGray2
            }
            shouldPlay.toggle()
        }
        
    }

    // MARK: - 소리 재생하는 코드
    func playNotes(idx: Int) {
        guard let path = Bundle.main.path(forResource: "FX_piano_\(idx)", ofType:"mp3") else { return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleTextField.resignFirstResponder()
    }
}

// MARK: - 텍스트필드 델리게이트 설정
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "" && string == " " {
            textField.text = ""
            return false
        }
        warningLabel.textColor = .clear
        return true
    }
}
