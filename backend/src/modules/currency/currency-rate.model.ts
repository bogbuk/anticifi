import {
  Table, Column, Model, DataType, PrimaryKey, Default,
  AllowNull, CreatedAt, UpdatedAt, Index,
} from 'sequelize-typescript';

@Table({
  tableName: 'currency_rates',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      unique: true,
      fields: ['base_currency', 'target_currency', 'date'],
    },
  ],
})
export class CurrencyRate extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @AllowNull(false)
  @Column(DataType.STRING(3))
  declare baseCurrency: string;

  @AllowNull(false)
  @Column(DataType.STRING(3))
  declare targetCurrency: string;

  @AllowNull(false)
  @Column(DataType.DECIMAL(20, 10))
  declare rate: number;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare date: string;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;
}
